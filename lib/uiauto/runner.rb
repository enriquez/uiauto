require 'uiauto/instruments'
require 'uiauto/simulator'

module UIAuto
  class Runner
    def self.run(file_or_dir, options = {})
      exit_status = 0
      if file_or_dir.nil?
        exit_status = self.run_one options
      elsif File.directory?(file_or_dir)
        exit_status = self.run_all(file_or_dir, options)
      else
        exit_status = self.run_one(file_or_dir, options)
      end

      exit exit_status
    end

    private

    def self.run_one(script, options)
      self.process_comment_header script
      instruments = Instruments.new(script, options)
      exit_status = instruments.execute

      exit_status
    end

    def self.run_all(dir, options)
      exit_status = 0
      scripts = Dir.glob(File.join(dir, "*.js"))
      scripts.each do |script|
        script_exit_status = self.run_one(script, options)
        if script_exit_status > exit_status
          exit_status = script_exit_status
        end
      end

      exit_status
    end

    def self.process_comment_header(script)
      File.open(script) do |file|
        if file.readline =~ /\s*\/\/ setup_simulator_data "(.+)"/
          path = $1
          full_path = path
          if !path.start_with?("/")
            full_path = File.expand_path(File.join(File.dirname(script), path))
          end

          simulator = Simulator.new
          simulator.load full_path
        end
      end
    end

  end
end
