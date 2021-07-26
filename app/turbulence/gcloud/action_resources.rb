# frozen_string_literal: true

module Turbulence
  module GCloud
    # Building-blocks with which an Action can use Google Cloud resources in a uniform way.
    module ActionResources
      def project
        return @project if defined?(@project)

        @project = GCloud::Resources::Project.from(Config.get(:project_id))
        @project = GCloud::Resources::Project.select unless @project.valid?

        @project
      end

      def cluster
        return @cluster if defined?(@cluster)

        @cluster = GCloud::Resources::Cluster.from(Config.get(:cluster_name), Config.get(:cluster_region))
        @cluster = GCloud::Resources::Cluster.select(project) unless @cluster.valid?

        @cluster
      end

      def namespace
        return @namespace if defined?(@namespace)

        @namespace = GCloud::Resources::Namespace.from(Config.get(:namespace_name))
        @namespace = GCloud::Resources::Namespace.select(cluster) unless @namespace.valid?

        @namespace
      end

      def pod
        @pod ||= GCloud::Resources::Pod.select(namespace)
      end

      def deployment
        @deployment ||= GCloud::Resources::Deployment.select(namespace)
      end

      def container
        @container ||= GCloud::Resources::Container.select(namespace, pod)
      end
    end
  end
end
