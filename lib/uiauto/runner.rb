require 'uiauto/instruments'
require 'uiauto/simulator'
require 'uiauto/reporter'
require 'uiauto/formatters'
require 'uiauto/listeners'

module UIAuto
  class Runner
    def self.run(file_or_dir, options = {})
      @sdk = options[:sdk]

      if options[:require]
        require File.expand_path(options[:require])
      end

      @reporter = Reporter.new
      @exit_status_listener = Listeners::ExitStatusListener.new
      @reporter.add_listener(@exit_status_listener)

      listeners = options[:listeners] || []
      listeners.each do |listener|
        @reporter.add_listener(listener)
      end

      formatter = eval("Formatters::#{options[:format]}.new")
      @reporter.formatter = formatter

      @reporter.run_start

      exit_status = 0
      if file_or_dir.nil?
        self.run_one options
      elsif File.directory?(file_or_dir)
        self.run_all(file_or_dir, options)
      else
        self.run_one(file_or_dir, options)
      end

      @reporter.run_finish

      exit @exit_status_listener.result
    end

    private

    def self.run_one(script, options)
      relative_path = File.expand_path(script).sub(File.expand_path('.') + '/', '')
      @reporter.script_start(relative_path)
      self.process_comment_header script
      instruments = Instruments.new(script, @reporter, options)
      instruments.execute
      @reporter.script_finish(relative_path)
    end

    def self.run_all(dir, options)
      scripts = Dir.glob(File.join(dir, "*.js"))
      scripts.each do |script|
        self.run_one(script, options)
      end
    end

    def self.process_comment_header(script)
      File.open(script) do |file|
        if file.readline =~ /\s*\/\/ setup_simulator_data "(.+)"/
          path = $1
          full_path = path
          if !path.start_with?("/")
            full_path = File.expand_path(File.join(File.dirname(script), path))
          end

          relative_path = full_path.sub(File.expand_path('.') + '/', '')
          @reporter.load_simulator_data(relative_path)
          simulator = Simulator.new(@sdk)
          simulator.load full_path
        end
      end
    end

  end
end
