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
          namespace
          pod

          PROMPT.ok("\nConnecting...\n")
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

        def container
          @container ||= GCloud::Resources::Container.select
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
