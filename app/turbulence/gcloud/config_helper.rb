# frozen_string_literal: true

module Turbulence
  module GCloud
    # Business logic to use Turbulence::Config for Turbulence::GCloud
    module ConfigHelper
      module_function

      def init_config? # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        project = GCloud::Resources::Project.from(Config.get(:project_id))
        namespace = GCloud::Resources::Namespace.from(Config.get(:namespace_name))
        cluster = GCloud::Resources::Cluster.from(Config.get(:cluster_name), Config.get(:cluster_region))
        able_to_connect = project.valid? && namespace.valid? && cluster.valid?

        if able_to_connect
          PROMPT.say <<~ENDOFMSG
            ·  You have previously run this to connect to:
              · project: #{project.id}
              · cluster: #{cluster.name} [#{cluster.region}]
              · namespace: #{namespace.name}
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
