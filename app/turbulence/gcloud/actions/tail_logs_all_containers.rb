# frozen_string_literal: true

module Turbulence
  module GCloud
    module Actions
      # View logs from all containers in a pod
      class TailLogsAllContainers
        ID = :all_containers
        NAME = 'View logs from all containers in a pod'
        METHOD_NAME = :tail_logs_all_containers

        def initialize
          namespace = GCloud::Resources::Namespace.from(Config.get(:namespace_name))
          namespace = GCloud::Resources::Namespace.select unless namespace.valid?

          pod = GCloud::Resources::Pod.from(Config.get(:pod_id))
          pod = GCloud::Resources::Pod.select unless pod.valid?

          PROMPT.ok("\nConnecting...\n")
          system(%( kubectl logs -f #{pod.id} -n #{namespace.name} --all-containers ))
        end
      end
    end
  end
end
