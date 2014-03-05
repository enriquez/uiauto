require 'childprocess'
require 'fileutils'
require 'cfpropertylist'
require 'pty'
require 'uiauto/simulator'

module UIAuto
  class Instruments
    attr_accessor :trace, :app, :results, :script, :device, :simulator

    def initialize(script, reporter, opts = {})
      @reporter  = reporter
      @script    = script
      @trace     = opts[:trace]
      @results   = opts[:results]
      @device    = opts[:device]
      @simulator = opts[:simulator]
      @sdk       = opts[:sdk]
      @app       = opts[:app] || default_application

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
      launch_simulator unless device_id
      select_device_family unless device_id

      instruments = ChildProcess.build(*command.split(" "))
      master, slave = if PTY.respond_to?(:open)
                        PTY.open
                      else
                        [File.new("/dev/ptyuf", "w"), File.open("/dev/ttyuf", "r")]
                      end
      instruments.io.stdout = master
      instruments.io.stderr = master
      instruments.duplex = true
      instruments.start
      master.close

      begin
        loop do
          buffer = slave.readpartial(8192)
          @reporter.parse_instruments_output(buffer)
        end
      rescue EOFError
        @reporter.script_finish(@script)
      ensure
        slave.close
      end
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

    def launch_simulator
      Simulator.open(@simulator, @sdk)
    end

    def select_device_family
      if @simulator && !@simulator.empty?
        info_plist = CFPropertyList::List.new(:file => File.join(@app, "Info.plist"))
        data       = CFPropertyList.native_types(info_plist.value)
        if @simulator.start_with?("iPhone")
          data["UIDeviceFamily"] = [1]
        elsif @simulator.start_with?("iPad")
          data["UIDeviceFamily"] = [2]
        end

        info_plist.value = CFPropertyList.guess(data)
        info_plist.save
      end
    end

  end
end
