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

        def initialize
          namespace_name = Config.get(:namespace_name) || get_k8s_namespace
          pod_id = get_k8s_pods
          container_name = get_k8s_container

          command =
            PROMPT.select('Command to run:', SUGGESTED_COMMANDS, per_page: SUGGESTED_COMMANDS.length) ||
            PROMPT.ask('Command to run:', required: true)

          PROMPT.ok("\nConnecting...\n")
          system(%( kubectl exec -it #{pod_id} -n #{namespace_name} -c #{container_name} -- #{command} ))
        end
      end
    end
  end
end
