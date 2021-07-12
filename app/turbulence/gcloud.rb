# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Naming/AccessorMethodName

require_relative 'menu'
require 'yaml'

module Turbulence
  # Connector for Google Cloud
  module GCloud # rubocop:disable Metrics/ModuleLength
    PROMPT = Menu::PROMPT

    SUGGESTED_COMMANDS = [
      '/bin/bash',
      '/bin/sh',
      'bundle exec rails console',
      'bundle exec irb',

      { name: '(other)', value: nil }
    ].freeze

    module_function

    # rubocop:enable all

    def go!
      if File.exist?(Config::CONFIG_FILE)
        ConfigHelper.init_config? && Config.init_config!
      else
        Config.init_config!
      end

      auth_with_gcloud && action.new
    end

    go! unless defined?(RSpec)
  end
end
