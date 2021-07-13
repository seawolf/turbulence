# frozen_string_literal: true

module Turbulence
  module GCloud
    module Actions
      # Access a command line / console for a container
      class ConnectToContainer
        ID = :shell
        NAME = 'Access a command line / console for a container'
        METHOD_NAME = :connect_to_container

        SUGGESTED_COMMANDS = [
          '/bin/bash',
          '/bin/sh',
          'bundle exec rails console',
          'bundle exec irb',

          { name: '(other)', value: nil }
        ].freeze

        def initialize # rubocop:disable Metrics/AbcSize
          namespace = GCloud::Resources::Namespace.from(Config.get(:namespace_name))
          namespace = GCloud::Resources::Namespace.select unless namespace.valid?

          pod = GCloud::Resources::Pod.from(Config.get(:pod_id))
          pod = GCloud::Resources::Pod.select unless pod.valid?

          container = GCloud::Resources::Container.select

          command =
            PROMPT.select('Command to run:', SUGGESTED_COMMANDS, per_page: SUGGESTED_COMMANDS.length) ||
            PROMPT.ask('Command to run:', required: true)

          PROMPT.ok("\nConnecting...\n")
          system(%( kubectl exec -it #{pod.id} -n #{namespace.name} -c #{container.name} -- #{command} ))
        end
      end
    end
  end
end
