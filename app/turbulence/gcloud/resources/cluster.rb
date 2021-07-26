# frozen_string_literal: true

module Turbulence
  module GCloud
    module Resources
      # Google Cloud Cluster
      class Cluster
        def self.select(project) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
          cluster = from(Config.get(:cluster_name), Config.get(:cluster_region))
          unless cluster.valid?
            clusters_list = `gcloud container clusters list --format="value(name, zone)"` || exit(1)
            clusters = clusters_list.split("\n").map do |line|
              segments = line.split(/\s+/)
              Cluster.new(*segments)
            end

            choices = clusters.map do |c|
              {
                name: "#{c.name} (#{c.region})",
                value: c
              }
            end

            if choices.empty?
              raise "No Kubernetes clusters in the #{project_id} project! (It may be only a Cloud Run project.)"
            end

            cluster = Menu.auto_select("Kubernetes clusters in the \"#{project.id}\" project:", choices,
                                       per_page: choices.length)

            Config.set(:cluster_name, cluster.name)
            Config.set(:cluster_region, cluster.region)
          end

          PROMPT.say("\n·  Connecting to the #{cluster.name} cluster...")
          system(%( gcloud container clusters get-credentials #{cluster.name} --region #{cluster.region} --project #{project.id} 1> /dev/nulls)) || exit(1) # rubocop:disable Layout/LineLength

          cluster
        end

        def self.from(name, region)
          Cluster.new(name, region)
        end

        Cluster = Struct.new(:name, :region) do
          def valid?
            name.present? && region.present?
          end
        end
      end
    end
  end
end
