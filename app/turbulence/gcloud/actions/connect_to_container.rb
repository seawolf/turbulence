# frozen_string_literal: true

module Turbulence
  module GCloud
    module Actions
      # Access a command line / console for a container
      class ConnectToContainer
        ID = :shell
        NAME = 'Access a command line / console for a container'

        include ActionResources

        def run
          project
          cluster
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
          'bin/console',
          'bundle exec rails console',
          'bundle exec irb',

          { name: '(other)', value: nil }
        ].freeze

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
