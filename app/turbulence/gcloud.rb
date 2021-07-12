# frozen_string_literal: true

require_relative 'menu'
require 'yaml'

module Turbulence
  # Connector for Google Cloud
  module GCloud
    PROMPT = Menu::PROMPT

    module_function

    def go!
      if File.exist?(Config::CONFIG_FILE)
        ConfigHelper.init_config? && Config.init_config!
      else
        Config.init_config!
      end

      Auth.new && Action.new
    end

    go! unless defined?(RSpec)
  end
end
