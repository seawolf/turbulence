# frozen_string_literal: true

module Turbulence
  module GCloud
    module Actions
      # Restart a deployment of container(s)
      class RestartDeployment
        ID = :restart_deployment
        NAME = 'Restart a deployment of container(s)'
        METHOD_NAME = :restart_deployment

        def initialize
          namespace_name = get(:namespace_name) || get_k8s_namespace
          deployment_name = get_k8s_deployments

          PROMPT.ok("\nRestarting...\n")
          system(%( kubectl rollout restart -n #{namespace_name} deployment/#{deployment_name} ))
          PROMPT.ok('Please allow some time for the restart to complete.')
        end
      end
    end
  end
end
