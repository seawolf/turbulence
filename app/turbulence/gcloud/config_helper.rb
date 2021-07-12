# frozen_string_literal: true

module Turbulence
  module GCloud
    # Business logic to use Turbulence::Config for Turbulence::GCloud
    module ConfigHelper
      module_function

      def init_config? # rubocop:disable Metrics/MethodLength
        if (project_id = Config.get(:project_id)) &&
           (namespace_name = Config.get(:namespace_name)) &&
           (cluster_name = Config.get(:cluster_name)) &&
           (cluster_region = Config.get(:cluster_region))
          PROMPT.say <<~ENDOFMSG
            ·  You have previously run this to connect to:
              · project: #{project_id}
              · cluster: #{cluster_name} [#{cluster_region}]
              · namespace: #{namespace_name}
          ENDOFMSG

          choices = [
            { name: 'Yes', value: false },
            { name: 'No', value: true }
          ]
          return Menu.auto_select('Would you like to keep this selection?', choices)
        end

        true
      end
    end
  end
end
