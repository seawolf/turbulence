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
          namespace_name = Config.get(:namespace_name) || get_k8s_namespace
          pod_id = get_k8s_pods
          container_name = get_k8s_container

          PROMPT.ok("\nConnecting...\n")
          system(%( kubectl logs -f #{pod_id} -n #{namespace_name} -c #{container_name} ))
        end
      end
    end
  end
end
