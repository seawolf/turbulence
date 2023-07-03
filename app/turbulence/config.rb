# frozen_string_literal: true

module Turbulence
  # Interface for the configuration file
  module Config
    CONFIG_FILE = './config.yml'

    module_function

    def config
      # raise here when there is no config file, as `init_config!` should put one there first
      # rubocop:disable Style/YAMLFileRead,Security/YAMLLoad
      YAML.load(File.read(CONFIG_FILE)) || {}
      # rubocop:enable Style/YAMLFileRead,Security/YAMLLoad
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
