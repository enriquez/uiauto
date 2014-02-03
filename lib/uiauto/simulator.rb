require 'fileutils'

module UIAuto
  class Simulator
    DEFAULT_DEVICE = "iPhone Retina (4-inch 64-bit)"
    DEFAULT_SDK    = "7.0.3-64"

    SDK_ITEMS = {
      "6.1"      => "iOS 6.1 (10B141)",
      "7.0.3"    => "iOS 7.0.3 (11B508)",
      "7.0.3-64" => "iOS 7.0.3 (11B508)"
    }

    DEVICES = {
      "iPhone"                        => ["6.1"],
      "iPhone Retina (3.5-inch)"      => ["6.1", "7.0.3"],
      "iPhone Retina (4-inch)"        => ["6.1", "7.0.3"],
      "iPhone Retina (4-inch 64-bit)" => ["7.0.3-64"],
      "iPad"                          => ["6.1", "7.0.3"],
      "iPad Retina"                   => ["6.1", "7.0.3"],
      "iPad Retina (64-bit)"          => ["7.0.3-64"]
    }

    def initialize(sdk_version = DEFAULT_SDK)
      @sdk_version = sdk_version
      @simulator_environment_path = File.expand_path("~/Library/Application Support/iPhone Simulator")
    end

    def reset
      self.class.close
      FileUtils.rm_rf(simulator_data_path)
    end

    def load(data_path)
      source_directory      = Dir.glob("#{File.expand_path(data_path)}/#{@sdk_version}/*")
      destination_directory = simulator_data_path

      abort "Simulator Data at #{data_path.inspect} for SDK #{@sdk_version.inspect} not found" if source_directory.empty?

      reset
      FileUtils.mkdir_p(destination_directory)
      FileUtils.cp_r(source_directory, destination_directory)
    end

    def save(data_path)
      source_directory      = Dir.glob("#{simulator_data_path}/*")
      destination_directory = File.join(File.expand_path(data_path), @sdk_version)

      FileUtils.mkdir_p(destination_directory)
      FileUtils.cp_r(source_directory, destination_directory)
    end

    def self.close
      `killall "iPhone Simulator" &> /dev/null || true`
    end

    def self.open(simulator = DEFAULT_DEVICE, sdk = DEFAULT_SDK)
      if DEVICES.keys.include?(simulator) && DEVICES[simulator].include?(sdk)
        xcode_path     = `xcode-select --print-path`.strip
        simulator_path = File.join(xcode_path, "/Platforms/iPhoneSimulator.platform/Developer/Applications/iPhone Simulator.app")

        `open "#{simulator_path}"`

        sdk_item = SDK_ITEMS[sdk]
        uiauto_root = Gem::Specification.find_by_name("uiauto").gem_dir
        choose_sim_device = File.join(uiauto_root, "helpers/choose_sim_device")
        `#{choose_sim_device} "#{simulator}" "#{sdk_item}"`
      elsif !simulator.nil?
        puts "Invalid simulator: \"#{simulator}\" \"#{sdk}\""
      end
    end

    private

    def simulator_data_path
      File.join(@simulator_environment_path, @sdk_version)
    end
  end
end
