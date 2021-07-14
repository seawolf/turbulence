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
          namespace
          pod

          connect
        end

        def namespace
          return @namespace if defined?(@namespace)

          @namespace = GCloud::Resources::Namespace.from(Config.get(:namespace_name))
          @namespace = GCloud::Resources::Namespace.select unless @namespace.valid?

          @namespace
        end

        def pod
          return @pod if defined?(@pod)

          @pod = GCloud::Resources::Pod.from(Config.get(:pod_id))
          @pod = GCloud::Resources::Pod.select unless @pod.valid?

          @pod
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
