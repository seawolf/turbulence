# frozen_string_literal: true

module Turbulence
  module GCloud
    module Resources
      # Google Cloud Deployment
      class Deployment
        def self.select # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
          namespace = GCloud::Resources::Namespace.from(Config.get(:namespace_name))
          namespace = GCloud::Resources::Namespace.select unless namespace.valid?

          deployments_list = `kubectl get deployments -n #{namespace.name} -o jsonpath='{range .items[*]}{.metadata.name}{"\\n"}{end}'` || exit(1) # rubocop:disable Layout/LineLength
          deployments = deployments_list.split("\n").map do |line|
            Deployment.new(line)
          end

          choices = deployments.map do |d|
            {
              name: d.name,
              value: d
            }
          end

          raise "No deployments in the #{namespace.name} namespace!" if choices.empty?

          deployment = Menu.auto_select("Deployments in the \"#{namespace.name}\" namespace:", choices,
                                        per_page: choices.length)

          Config.set(:deployment_name, deployment.name)

          deployment
        end

        def self.from(name)
          Deployment.new(name)
        end

        Deployment = Struct.new(:name) do
          def valid?
            name.present?
          end
        end
      end
    end
  end
end
