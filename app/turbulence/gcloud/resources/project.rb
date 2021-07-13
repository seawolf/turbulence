# frozen_string_literal: true

module Turbulence
  module GCloud
    module Resources
      # Google Cloud Project
      class Project
        def self.select # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
          project = GCloud::Resources::Project.from(Config.get(:project_id))
          unless project.valid?
            projects_list = `gcloud projects list --format="value(projectId, name)"` || exit(1)
            projects = projects_list.split("\n").map do |line|
              segments = line.split(/\s+/)
              Project.new(segments[0], segments[1..-1].join(' '))
            end

            choices = projects.map do |p|
              {
                name: "#{p.name} (#{p.id})",
                value: p
              }
            end

            project = Menu.auto_select('Projects in your Google Cloud:', choices, per_page: choices.length)
            Config.set(:project_id, project.id)
          end

          PROMPT.say("\nSelecting the project \"#{project.id}\" as active...")
          system(%( gcloud config set project #{project.id} 1> /dev/null )) || exit(1)

          project
        end

        def self.from(id, name = nil)
          Project.new(id, name)
        end

        Project = Struct.new(:id, :name) do
          def valid?
            id.present?
          end
        end
      end
    end
  end
end
