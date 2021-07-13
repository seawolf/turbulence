# frozen_string_literal: true

module Turbulence
  module GCloud
    module Actions
      # View logs from one container in a pod
      class TailLogsSingleContainer
        ID = :one_container
        NAME = 'View logs from one container in a pod'
        METHOD_NAME = :tail_logs_single_container

        def initialize
          namespace = GCloud::Resources::Namespace.from(Config.get(:namespace_name))
          namespace = GCloud::Resources::Namespace.select unless namespace.valid?

          pod = GCloud::Resources::Pod.from(Config.get(:pod_id))
          pod = GCloud::Resources::Pod.select unless pod.valid?

          container = GCloud::Resources::Container.select

          PROMPT.ok("\nConnecting...\n")
          system(%( kubectl logs -f #{pod.id} -n #{namespace.name} -c #{container.name} ))
        end
      end
    end
  end
end
