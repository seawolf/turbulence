# frozen_string_literal: true

module Turbulence
  module GCloud
    module Resources
      # Google Cloud Project
      class Project
        def self.select
          new.tap(&:fetch).project
        end

        def self.from(id, _name = nil)
          Project.new(id)
        end

        attr_reader :project

        def fetch
          @project = cached_project do
            Menu.auto_select('Projects in your Google Cloud:', choices, per_page: choices.length)
          end

          activate
        end

        private

        PROJECTS_LIST_COMMAND = 'gcloud projects list --format="value(projectId, name)"'

        attr_writer :project

        def cached_project
          project = self.class.from(Config.get(:project_id))

          project = self.cached_project = yield unless project.valid?

          project
        end

        def cached_project=(project)
          Config.set(:project_id, project.id)
        end

        # :nocov:
        def projects_list
          `#{PROJECTS_LIST_COMMAND}`.tap do |result|
            result || exit(1)
          end
        end
        # :nocov:

        def projects
          projects_list.split("\n").map do |line|
            segments = line.split(/\s+/)
            Project.new(segments[0], segments[1..-1].join(' '))
          end
        end

        def choices
          projects.map(&:to_choice)
        end

        # :nocov:
        def activate
          `gcloud config set project #{project.id} 1> /dev/null`.tap do |result|
            result || exit(1)
          end
        end
        # :nocov:

        Project = Struct.new(:id, :name) do
          def to_choice
            {
              name: "#{name} (#{id})",
              value: self
            }
          end

          def valid?
            id.present?
          end
        end
      end
    end
  end
end
