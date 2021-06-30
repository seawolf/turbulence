# frozen_string_literal: true

module Turbulence
  # Interface for the configuration file
  module Config
    CONFIG_FILE = './config.yml'

    module_function

    def config
      YAML.load(File.read(CONFIG_FILE)) || {} # rubocop:disable Security/YAMLLoad
    end

    def config!(data)
      File.write(CONFIG_FILE, YAML.dump(data))
      data
    end

    def get(key)
      config[key]
    end

    def set(key, value)
      data = config
      data[key] = value
      config!(data)
      value
    end

    def init_config!
      File.write(CONFIG_FILE, YAML.dump({}))
    end
  end
end
