# frozen_string_literal: true

module Turbulence
  module GCloud
    module Actions
      # Restart a deployment of container(s)
      class RestartDeployment
        ID = :restart_deployment
        NAME = 'Restart a deployment of container(s)'

        include ActionResources

        def run
          project
          cluster
          namespace
          deployment

          PROMPT.ok("\nRestarting...\n")
          connect
          PROMPT.ok('Please allow some time for the restart to complete.')
        end

        private

        def connection
          "kubectl rollout restart -n #{namespace.name} deployment/#{deployment.name}"
        end

        def connect
          system(connection)
        end
      end
    end
  end
end
