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
          namespace
          deployment

          PROMPT.ok("\nRestarting...\n")
          connect
          PROMPT.ok('Please allow some time for the restart to complete.')
        end

        private

        def namespace
          return @namespace if defined?(@namespace)

          @namespace = GCloud::Resources::Namespace.from(Config.get(:namespace_name))
          @namespace = GCloud::Resources::Namespace.select unless @namespace.valid?

          @namespace
        end

        def deployment
          @deployment = GCloud::Resources::Deployment.select
        end

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
