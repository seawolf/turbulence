# frozen_string_literal: true

module Turbulence
  module GCloud
    module Actions
      # View logs from all containers in a pod
      class TailLogsAllContainers
        ID = :all_containers
        NAME = 'View logs from all containers in a pod'

        include ActionResources

        def run
          project
          cluster
          namespace
          pod

          PROMPT.ok("\nConnecting...\n")
          connect
        end

        def connection
          "kubectl logs -f #{pod.id} -n #{namespace.name} --all-containers"
        end

        def connect
          system(connection)
        end
      end
    end
  end
end
