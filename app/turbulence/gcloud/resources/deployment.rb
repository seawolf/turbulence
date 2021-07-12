# frozen_string_literal: true

module Turbulence
  module GCloud
    module Resources
      # Google Cloud Deployment
      class Deployment
        def initialize # rubocop:disable Metrics/MethodLength
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

          deployment = Menu.auto_select("Deployments in the \"#{namespace_name}\" namespace:", choices,
                                        per_page: choices.length)
          Config.set(:deployment_name, deployment.name)
        end

        Deployment = Struct.new(:name)
      end
    end
  end
end
