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

    Namespace = Struct.new(:name)
    def get_k8s_namespace # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      cluster_name = Config.get(:cluster_name) || get_k8s_cluster[0]
      namespace_name = Config.get(:namespace_name)

      return namespace_name if namespace_name

      namespaces_list = `kubectl get namespaces -o jsonpath='{range .items[*]}{.metadata.name}{"\\n"}{end}'` || exit(1)
      namespaces = namespaces_list.split("\n").map do |line|
        Namespace.new(line)
      end

      choices = namespaces.map do |namespace|
        {
          name: namespace.name,
          value: namespace
        }
      end

      raise "No Kubernetes namespaces in the #{cluster_name} cluster!" if choices.empty?

      namespace = Menu.auto_select("Kubernetes namespaces in the \"#{cluster_name}\" cluster:", choices, per_page: choices.length)
      namespace_name = Config.set(:namespace_name, namespace.name)

      Config.set(:namespace_name, namespace_name)
    end

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

    Pod = Struct.new(:id)
    def get_k8s_pods # rubocop:disable Metrics/MethodLength
      namespace_name = Config.get(:namespace_name) || get_k8s_namespace

      pods_list = `kubectl get pods -n #{namespace_name} -o jsonpath='{range .items[*]}{.metadata.name}{"\\n"}{end}' | grep foreground` || exit(1)
      pods = pods_list.split("\n").map do |line|
        Pod.new(line)
      end

      choices = pods.map do |pod|
        {
          name: pod.id,
          value: pod
        }
      end

      raise "No Kubernetes pods in the #{namespace_name} namespace!" if choices.empty?

      pod = Menu.auto_select("Pods in the \"#{namespace_name}\" namespace:", choices, per_page: choices.length)
      Config.set(:pod_id, pod.id)
    end

    Container = Struct.new(:name)
    def get_k8s_container # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      namespace_name = Config.get(:namespace_name) || get_k8s_namespace
      pod_id = Config.get(:pod_id) || get_k8s_pods

      containers_list = `kubectl get pods -n #{namespace_name} #{pod_id} -o jsonpath='{range .spec.containers[*]}{.name}{"\\n"}{end}'` || exit(1)
      containers = containers_list.split("\n").map do |line|
        Container.new(line)
      end

      choices = containers.map do |container|
        {
          name: container.name,
          value: container
        }
      end

      raise "No containers in the #{pod_id} pod!" if choices.empty?

      container = Menu.auto_select("Containers in the \"#{pod_id}\" pod:", choices, per_page: choices.length)
      Config.set(:container_name, container.name)
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
