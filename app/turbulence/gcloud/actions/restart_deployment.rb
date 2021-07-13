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
          namespace = GCloud::Resources::Namespace.from(Config.get(:namespace_name))
          namespace = GCloud::Resources::Namespace.select unless namespace.valid?

          deployment = GCloud::Resources::Deployment.select

          PROMPT.ok("\nRestarting...\n")
          system(%( kubectl rollout restart -n #{namespace.name} deployment/#{deployment.name} ))
          PROMPT.ok('Please allow some time for the restart to complete.')
        end
      end
    end
  end
end
