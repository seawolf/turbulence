# frozen_string_literal: true

module Turbulence
  module GCloud
    module Actions
      # View logs from one container in a pod
      class TailLogsSingleContainer
        ID = :one_container
        NAME = 'View logs from one container in a pod'

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
          "kubectl logs -f #{pod.id} -n #{namespace.name} -c #{container.name}"
        end

        def connect
          system(connection)
        end
      end
    end
  end
end
