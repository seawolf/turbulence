# frozen_string_literal: true

module Turbulence
  module GCloud
    module Actions
      # View logs from all containers in a pod
      class TailLogsAllContainers
        ID = :all_containers
        NAME = 'View logs from all containers in a pod'
        METHOD_NAME = :tail_logs_all_containers

        include ActionResources

        def initialize
          project
          cluster
          namespace
          pod

          connect
        end

        def connection
          "kubectl logs -f #{pod.id} -n #{namespace.name} --all-containers"
        end

        def connect
          PROMPT.ok("\nConnecting...\n")
          system(connection)
        end
      end
    end
  end
end
