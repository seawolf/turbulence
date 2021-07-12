# frozen_string_literal: true

module Turbulence
  module GCloud
    module Resources
      # Google Cloud Cluster
      class Cluster
        def initialize # rubocop:disable Metrics/MethodLength
          unless (project_id = Config.get(:project_id))
            get_gcloud_project
            project_id = Config.get(:project_id)
          end

          unless (cluster_name = Config.get(:cluster_name) && cluster_region = Config.get(:cluster_region))
            clusters_list = `gcloud container clusters list --format="value(name, zone)"` || exit(1)
            clusters = clusters_list.split("\n").map do |line|
              segments = line.split(/\s+/)
              Cluster.new(*segments)
            end

            choices = clusters.map do |cluster|
              {
                name: "#{cluster.name} (#{cluster.region})",
                value: cluster
              }
            end

            if choices.empty?
              raise "No Kubernetes clusters in the #{project_id} project! (It may be only a Cloud Run project.)"
            end

            cluster = Menu.auto_select("Kubernetes clusters in the \"#{project_id}\" project:", choices,
                                       per_page: choices.length)

            cluster_name = Config.set(:cluster_name, cluster.name)
            cluster_region = Config.set(:cluster_region, cluster.region)
          end

          PROMPT.say("\n·  Connecting to the #{cluster_name} cluster...")
          system(%( gcloud container clusters get-credentials #{cluster_name} --region #{cluster_region} --project #{project_id} 1> /dev/nulls)) || exit(1)

          [cluster_name, cluster_region]
        end

        Cluster = Struct.new(:name, :region)
      end
    end
  end
end
