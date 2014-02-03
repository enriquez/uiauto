require 'thor'
require 'uiauto/simulator'
require 'uiauto/runner'

module UIAuto
  class SimulatorCLI < Thor
    namespace :simulator

    desc "reset", "Deletes all applications and settings"
    method_option :sdk, :default => Simulator::DEFAULT_SDK
    def reset
      simulator = Simulator.new(options[:sdk])
      simulator.reset
    end

    desc "load DATA", "Loads previously saved simulator data"
    method_option :sdk, :default => Simulator::DEFAULT_SDK
    def load(data_path)
      simulator = Simulator.new(options[:sdk])
      simulator.load(data_path)
    end

    desc "save DATA", "Saves simulator data"
    method_option :sdk, :default => Simulator::DEFAULT_SDK
    def save(data_path)
      simulator = Simulator.new(options[:sdk])
      simulator.save(data_path)
    end

    desc "open", "Opens the simulator"
    method_option :simulator,
      :default => Simulator::DEFAULT_DEVICE,
      :enum => Simulator::DEVICES,
      :desc => %q{Run the simulator for a specific device.}
    method_option :sdk, :default => Simulator::DEFAULT_SDK
    def open
      Simulator.open(options[:simulator], options[:sdk])
    end

    desc "close", "Closes the simulator"
    def close
      Simulator.close
    end

    desc "list", "List all possible simulator and sdk combinations"
    def list
      table = []
      Simulator::DEVICES.keys.each do |simulator|
        sdks = Simulator::DEVICES[simulator]
        sdks.each do |sdk|
          table << [simulator, sdk]
        end
      end

      print_table table
    end
  end

  class CLI < Thor
    desc "exec FILE_OR_DIRECTORY", "Runs the given script or directory of scripts through UI Automation"
    method_option :results,
      :default => File.expand_path("./uiauto/results"),
      :desc  => %q{Location where results should be saved. A directory named "Run ##" is created in here.}
    method_option :trace,
      :default => File.expand_path("./uiauto/results/trace"),
      :desc  => %q{Location of trace file. Created if it doesn't exist.}
    method_option :app,
      :desc => %q{Location of your application bundle. Defaults to your project's most recent build located in the standard derived data location.}
    method_option :device,
      :desc => %q{Run scripts on a connected device. Specify a UDID to target a specific device.}
    method_option :simulator,
      :default => Simulator::DEFAULT_DEVICE,
      :enum => Simulator::DEVICES,
      :desc => %q{Run the simulator for a specific device.}
    method_option :sdk, :default => Simulator::DEFAULT_SDK
    method_option :format,
      :default => "ColorIndentFormatter",
      :desc => %q{Formatter to use for output. Combine with --require to include a custom formatter. Built-in Formatters:
                           # ColorIndentFormatter: Adds readability to instruments output by filtering noise and adding color and indents.
                           # InstrumentsFormatter: Unmodified instruments output.}
    method_option :listeners,
      :type => :array,
      :banner => "LISTENERS",
      :desc => %q{Space separated list of class names used to listen to instruments output events. Combine with --require to include custom listeners.}
    method_option :require,
      :desc => %q{Path to a ruby file. Used to require custom formatters or listeners.}
    def exec(file_or_dir = "./uiauto/scripts/")
      Runner.run(file_or_dir, options)
    end

    desc "simulator SUBCOMMAND ...ARGS", "Manage simulator data"
    subcommand "simulator", SimulatorCLI
  end
end
