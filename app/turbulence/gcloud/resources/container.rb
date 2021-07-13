# frozen_string_literal: true

module Turbulence
  module GCloud
    module Resources
      # Google Cloud Container
      class Container
        def self.select # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
          namespace = GCloud::Resources::Namespace.from(Config.get(:namespace_name))
          namespace = GCloud::Resources::Namespace.select unless namespace.valid?

          pod = GCloud::Resources::Pod.from(Config.get(:pod_id))
          pod = GCloud::Resources::Pod.select unless pod.valid?

          containers_list = `kubectl get pods -n #{namespace.name} #{pod.id} -o jsonpath='{range .spec.containers[*]}{.name}{"\\n"}{end}'` || exit(1) # rubocop:disable Layout/LineLength
          containers = containers_list.split("\n").map do |line|
            Container.new(line)
          end

          choices = containers.map do |c|
            {
              name: c.name,
              value: c
            }
          end

          raise "No containers in the #{pod.id} pod!" if choices.empty?

          container = Menu.auto_select("Containers in the \"#{pod.id}\" pod:", choices, per_page: choices.length)
          Config.set(:container_name, container.name)

          container
        end

        def self.from(name)
          Container.new(name)
        end

        Container = Struct.new(:name) do
          def valid?
            name.present?
          end
        end
      end
    end
  end
end
