# frozen_string_literal: true

module Turbulence
  module GCloud
    module Actions
      # Access a command line / console for a container
      class ConnectToContainer
        ID = :shell
        NAME = 'Access a command line / console for a container'
        METHOD_NAME = :connect_to_container

        def initialize
          namespace
          pod
          container
          command

          PROMPT.ok("\nConnecting...\n")
          connect
        end

        private

        SUGGESTED_COMMANDS = [
          '/bin/bash',
          '/bin/sh',
          'bundle exec rails console',
          'bundle exec irb',

          { name: '(other)', value: nil }
        ].freeze

        def namespace
          return @namespace if defined?(@namespace)

          @namespace = GCloud::Resources::Namespace.from(Config.get(:namespace_name))
          @namespace = GCloud::Resources::Namespace.select unless @namespace.valid?

          @namespace
        end

        def pod
          return @pod if defined?(@pod)

          @pod = GCloud::Resources::Pod.from(Config.get(:pod_id))
          @pod = GCloud::Resources::Pod.select unless pod.valid?

          @pod
        end

        def container
          @container ||= GCloud::Resources::Container.select
        end

        def command
          return @command if defined?(@command)

          @command =
            PROMPT.select('Command to run:', SUGGESTED_COMMANDS, per_page: SUGGESTED_COMMANDS.length) ||
            PROMPT.ask('Command to run:', required: true)
        end

        def connection
          "kubectl exec -it #{pod.id} -n #{namespace.name} -c #{container.name} -- #{command}"
        end

        def connect
          system(connection)
        end
      end
    end
  end
end
