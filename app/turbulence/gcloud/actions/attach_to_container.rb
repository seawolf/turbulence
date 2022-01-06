# frozen_string_literal: true

module Turbulence
  module GCloud
    module Actions
      # Attach to a running container in a pod
      class AttachToContainer
        ID = :attach
        NAME = 'Attach to a running container in a pod'

        include ActionResources

        def run
          project
          cluster
          namespace
          pod
          container

          PROMPT.ok("\nConnecting...\n")
          connect
        end

        private

        def connection
          "kubectl attach -it #{pod.id} -n #{namespace.name} -c #{container.name}"
        end

        def connect
          system(connection)
        end
      end
    end
  end
end
