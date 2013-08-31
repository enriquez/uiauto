require 'childprocess'
require 'fileutils'
require 'cfpropertylist'

module UIAuto
  class Instruments
    attr_accessor :trace, :app, :results, :script, :device

    def initialize(script, opts = {})
      @script  = script
      @trace   = opts[:trace]
      @results = opts[:results]
      @device  = opts[:device]
      @app     = opts[:app] || default_application

      FileUtils.mkdir_p(@results) unless File.exists?(@results)
    end

    def command
      command = ["xcrun instruments"]
      command << "-w #{device_id}" if device_id
      command << "-D #{@trace}"
      command << "-t #{automation_template_location}"
      command << @app
      command << "-e UIASCRIPT #{@script}"
      command << "-e UIARESULTSPATH #{@results}"

      command.join(" ")
    end

    def execute
      exit_status = 0
      instruments = ChildProcess.build(*command.split(" "))
      master = File.new("/dev/ptyuf", "w")
      slave  = File.open("/dev/ttyuf", "r")
      instruments.io.stdout = master
      instruments.io.stderr = master
      instruments.duplex = true
      instruments.start
      master.close

      begin
        loop do
          buffer = slave.readpartial(8192)
          lines  = buffer.split("\n")
          lines.each do |line|
            puts line
            exit_status = 1 if line =~ /Fail:/ && exit_status != 2
            exit_status = 2 if line =~ /Instruments Usage Error|Instruments Trace Error|^\d+-\d+-\d+ \d+:\d+:\d+ [-+]\d+ (Error:|None: Script threw an uncaught JavaScript error)/
          end
        end
      rescue EOFError
      ensure
        slave.close
      end

      exit_status
    end

    protected

    def default_application
      current_dir = Dir.pwd
      product_directories = Dir.glob(File.join(derived_data_location, "*"))

      matching_directories = product_directories.select do |product_dir|
        info_plist_file = File.join(product_dir, "info.plist")
        if File.exists?(info_plist_file)
          info_plist = CFPropertyList::List.new(:file => info_plist_file)
          data       = CFPropertyList.native_types(info_plist.value)
          current_dir == File.dirname(data["WorkspacePath"])
        else
          false
        end
      end

      sorted_matches = matching_directories.sort_by { |dir| File.mtime(dir) }
      build_products_directory = device_id ? "Build/Products/*-iphoneos/*.app" : "Build/Products/*-iphonesimulator/*.app"
      Dir.glob(File.join(sorted_matches.last, build_products_directory)).sort_by { |dir| File.mtime(dir) }.last
    end

    def automation_template_location
      template = nil
      `xcrun instruments -s 2>&1 | grep Automation.tracetemplate`.split("\n").each do |path|
        path = path.gsub(/^\s*"|",\s*$/, "")
        template = path if File.exists?(path)
        break if template
      end
      template
    end

    def derived_data_location
      # TODO: Parse ~/Library/Preferences/com.apple.dt.Xcode.plist to find customized location
      File.expand_path("~/Library/Developer/Xcode/DerivedData/")
    end

    def device_id
      @device_id ||= begin
        if @device == 'device'
          ioreg = `ioreg -w 0 -rc IOUSBDevice -k SupportsIPhoneOS`
          ioreg[/"USB Serial Number" = "([0-9a-z]+)"/] && $1
        else
          @device
        end
      end
    end

  end
end
