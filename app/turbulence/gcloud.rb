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

    Deployment = Struct.new(:name)
    def get_k8s_deployments # rubocop:disable Metrics/MethodLength
      namespace_name = Config.get(:namespace_name) || get_k8s_namespace

      deployments_list = `kubectl get deployments -n #{namespace_name} -o jsonpath='{range .items[*]}{.metadata.name}{"\\n"}{end}'` || exit(1)
      deployments = deployments_list.split("\n").map do |line|
        Deployment.new(line)
      end

      choices = deployments.map do |deployment|
        {
          name: deployment.name,
          value: deployment
        }
      end

      raise "No deployments in the #{namespace_name} namespace!" if choices.empty?

      deployment = Menu.auto_select("Deployments in the \"#{namespace_name}\" namespace:", choices, per_page: choices.length)
      Config.set(:deployment_name, deployment.name)
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
