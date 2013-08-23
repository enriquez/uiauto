require 'thor'
require 'uiauto/simulator'
require 'uiauto/runner'

module UIAuto
  class SimulatorCLI < Thor
    namespace :simulator

    desc "reset", "Deletes all applications and settings"
    method_option :sdk, :default => Simulator::CURRENT_IOS_SDK_VERSION
    def reset
      simulator = Simulator.new(options[:sdk])
      simulator.reset
    end

    desc "load DATA", "Loads previously saved simulator data"
    method_option :sdk, :default => Simulator::CURRENT_IOS_SDK_VERSION
    def load(data_path)
      simulator = Simulator.new(options[:sdk])
      simulator.load(data_path)
    end

    desc "save DATA", "Saves simulator data"
    method_option :sdk, :default => Simulator::CURRENT_IOS_SDK_VERSION
    def save(data_path)
      simulator = Simulator.new(options[:sdk])
      simulator.save(data_path)
    end

    desc "open", "Opens the simulator"
    def open
      Simulator.open
    end

    desc "close", "Closes the simulator"
    def close
      Simulator.close
    end
  end

  class CLI < Thor
    desc "exec FILE_OR_DIRECTORY", "Runs the given script or directory of scripts through UI Automation"
    method_option :results, :default => File.expand_path("./uiauto/results")
    method_option :trace,   :default => File.expand_path("./uiauto/results/trace")
    method_option :app
    method_option :device
    method_option :permission, :type => :boolean
    def exec(file_or_dir = "./uiauto/scripts/")
      if options[:permission]
        default_name = `whoami`.chop
        name     = ask("Name (#{default_name}):")
        password = ask("Password:", :echo => false)

        if name == '' || name.nil?
          name = default_name
        end

        Runner.run(file_or_dir, options.merge({
          :name     => name,
          :password => password
        }))
      else
        Runner.run(file_or_dir, options)
      end
    end

    desc "simulator SUBCOMMAND ...ARGS", "manage simulator data"
    subcommand "simulator", SimulatorCLI
  end
end
