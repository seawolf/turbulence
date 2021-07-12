# frozen_string_literal: true

module Turbulence
  module GCloud
    module Resources
      # Google Cloud Container
      class Container
        def initialize # rubocop:disable Metrics/MethodLength
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

        Container = Struct.new(:name)
      end
    end
  end
end
