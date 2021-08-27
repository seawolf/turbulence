# frozen_string_literal: true

module Turbulence
  module GCloud
    module Resources
      # Google Cloud Cluster
      class Cluster
        def self.select(project)
          new(project).tap(&:fetch).cluster
        end

        def self.from(name, region)
          Cluster.new(name, region)
        end

        attr_reader :cluster

        def initialize(project)
          @project = project
        end

        def fetch
          @cluster = cached_cluster do
            if choices.empty?
              raise "No Kubernetes clusters in the #{project.id} project! (It may be only a Cloud Run project.)"
            end

            Menu.auto_select("Kubernetes clusters in the \"#{project.id}\" project:", choices,
                             per_page: choices.length)
          end

          activate
        end

        private

        CLUSTERS_LIST_COMMAND = 'gcloud container clusters list --format="value(name, zone)"'

        attr_reader :project
        attr_writer :cluster

        def cached_cluster
          cluster = self.class.from(Config.get(:cluster_name), Config.get(:cluster_region))

          cluster = self.cached_cluster = yield unless cluster.valid?

          cluster
        end

        def cached_cluster=(cluster)
          Config.set(:cluster_name, cluster.name)
          Config.set(:cluster_region, cluster.region)
        end

        # :nocov:
        def clusters_list
          `#{CLUSTERS_LIST_COMMAND}`.tap do |result|
            result || exit(1)
          end
        end
        # :nocov:

        def clusters
          clusters_list.split("\n").map do |line|
            segments = line.split(/\s+/)
            Cluster.new(*segments)
          end
        end

        def choices
          clusters.map(&:to_choice)
        end

        # :nocov:
        def activate_command
          "gcloud container clusters get-credentials #{cluster.name}"\
            " --region #{cluster.region}"\
            " --project #{project.id}"\
            ' 1> /dev/null'
        end

        def activate
          PROMPT.say("\n·  Connecting to the #{cluster.name} cluster...")
          `#{activate_command}`.tap do |result|
            result || exit(1)
          end

          cluster
        end
        # :nocov:

        Cluster = Struct.new(:name, :region) do
          def to_choice
            {
              name: "#{name} (#{region})",
              value: self
            }
          end

          def valid?
            name.present? && region.present?
          end
        end
      end
    end
  end
end
