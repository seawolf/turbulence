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

    Action = Struct.new(:id, :name, :class_name) do
      def to_choice
        {
          name: name,
          value: self
        }
      end
    end
    def action
      choices = Actions::LIST
                .map { |action| Action.new(action::ID, action::NAME, action) }
                .map(&:to_choice)

      action = Menu.auto_select('Select your desired action:', choices, per_page: choices.length)
      Config.set(:action, action.id)

      action.class_name
    end

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
