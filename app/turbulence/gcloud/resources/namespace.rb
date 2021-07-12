# frozen_string_literal: true

module Turbulence
  module GCloud
    module Resources
      # Google Cloud Namespace
      class Namespace
        def initialize # rubocop:disable Metrics/MethodLength
          cluster_name = Config.get(:cluster_name) || get_k8s_cluster[0]
          namespace_name = Config.get(:namespace_name)

          return namespace_name if namespace_name

          namespaces_list = `kubectl get namespaces -o jsonpath='{range .items[*]}{.metadata.name}{"\\n"}{end}'` || exit(1)
          namespaces = namespaces_list.split("\n").map do |line|
            Namespace.new(line)
          end

          choices = namespaces.map do |namespace|
            {
              name: namespace.name,
              value: namespace
            }
          end

          raise "No Kubernetes namespaces in the #{cluster_name} cluster!" if choices.empty?

          namespace = Menu.auto_select("Kubernetes namespaces in the \"#{cluster_name}\" cluster:", choices,
                                       per_page: choices.length)
          namespace_name = Config.set(:namespace_name, namespace.name)

          Config.set(:namespace_name, namespace_name)
        end

        Namespace = Struct.new(:name)
      end
    end
  end
end
