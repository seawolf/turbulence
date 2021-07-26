# frozen_string_literal: true

module Turbulence
  module GCloud
    module Resources
      # Google Cloud Namespace
      class Namespace
        def self.select(cluster) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
          namespace = from(Config.get(:namespace_name))
          return namespace if namespace.valid?

          namespaces_list = `kubectl get namespaces -o jsonpath='{range .items[*]}{.metadata.name}{"\\n"}{end}'` || exit(1) # rubocop:disable Layout/LineLength
          namespaces = namespaces_list.split("\n").map do |line|
            Namespace.new(line)
          end

          choices = namespaces.map do |n|
            {
              name: n.name,
              value: n
            }
          end

          raise "No Kubernetes namespaces in the #{cluster.name} cluster!" if choices.empty?

          namespace = Menu.auto_select("Kubernetes namespaces in the \"#{cluster.name}\" cluster:", choices,
                                       per_page: choices.length)

          Config.set(:namespace_name, namespace.name)

          namespace
        end

        def self.from(name)
          Namespace.new(name)
        end

        Namespace = Struct.new(:name) do
          def valid?
            name.present?
          end
        end
      end
    end
  end
end
