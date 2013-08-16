require 'fileutils'

module UIAuto
  class Simulator
    CURRENT_IOS_SDK_VERSION = "6.1"

    def initialize(sdk_version = CURRENT_IOS_SDK_VERSION)
      @sdk_version = sdk_version
      @simulator_environment_path = File.expand_path("~/Library/Application Support/iPhone Simulator")
    end

    def reset
      self.class.close
      FileUtils.rm_rf(simulator_data_path)
    end

    def load(data_path)
      source_directory      = Dir.glob("#{File.expand_path(data_path)}/*")
      destination_directory = simulator_data_path

      reset
      FileUtils.mkdir_p(destination_directory)
      FileUtils.cp_r(source_directory, destination_directory)
    end

    def save(data_path)
      source_directory      = Dir.glob("#{simulator_data_path}/*")
      destination_directory = File.expand_path(data_path)

      FileUtils.mkdir_p(destination_directory)
      FileUtils.cp_r(source_directory, destination_directory)
    end

    def self.close
      `killall "iPhone Simulator" &> /dev/null || true`
    end

    def self.open
      xcode_path     = `xcode-select -p`.strip
      simulator_path = File.join(xcode_path, "/Platforms/iPhoneSimulator.platform/Developer/Applications/iPhone Simulator.app")

      `open "#{simulator_path}"`
    end

    private

    def simulator_data_path
      File.join(@simulator_environment_path, @sdk_version)
    end
  end
end
