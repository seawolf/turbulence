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
          namespace_name = Config.get(:namespace_name) || get_k8s_namespace
          pod_id = get_k8s_pods

          PROMPT.ok("\nConnecting...\n")
          system(%( kubectl logs -f #{pod_id} -n #{namespace_name} --all-containers ))
        end
      end
    end
  end
end
