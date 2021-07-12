# frozen_string_literal: true

module Turbulence
  module GCloud
    module Resources
      # Google Cloud Project
      class Project
        def initialize # rubocop:disable Metrics/MethodLength
          Config.get(:last_auth) || auth_with_gcloud

          unless (project_id = Config.get(:project_id))
            projects_list = `gcloud projects list --format="value(projectId, name)"` || exit(1)
            projects = projects_list.split("\n").map do |line|
              segments = line.split(/\s+/)
              Project.new(segments[0], segments[1..-1].join(' '))
            end

            choices = projects.map do |project|
              {
                name: "#{project.name} (#{project.id})",
                value: project
              }
            end

            project = Menu.auto_select('Projects in your Google Cloud:', choices, per_page: choices.length)
            project_id = Config.set(:project_id, project.id)
          end

          PROMPT.say("\nSelecting the project \"#{project_id}\" as active...")
          system(%( gcloud config set project #{project_id} 1> /dev/null )) || exit(1)

          project_id
        end

        Project = Struct.new(:id, :name)
      end
    end
  end
end
