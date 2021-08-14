# frozen_string_literal: true

module Turbulence
  module GCloud
    module Resources
      # Google Cloud Namespace
      class Namespace
        def self.select(cluster)
          new(cluster).tap(&:fetch).namespace
        end

        def self.from(name)
          Namespace.new(name)
        end

        attr_reader :namespace

        def initialize(cluster)
          @cluster = cluster
        end

        def fetch
          raise "No Kubernetes namespaces in the #{cluster.name} cluster!" if choices.empty?

          @namespace = cached_namespace do
            Menu.auto_select("Kubernetes namespaces in the \"#{cluster.name}\" cluster:", choices,
                             per_page: choices.length)
          end
        end

        private

        NAMESPACES_LIST_COMMAND = "kubectl get namespaces -o jsonpath='" \
              '{range .items[*]}'\
              '{.metadata.name}'\
              '{"\n"}'\
              '{end}'\
              "'"

        attr_reader :cluster
        attr_writer :namespace

        def cached_namespace
          namespace = self.class.from(Config.get(:namespace_name))

          namespace = self.cached_namespace = yield unless namespace.valid?

          namespace
        end

        def cached_namespace=(namespace)
          Config.set(:namespace_name, namespace.name)
        end

        # :nocov:
        def namespaces_list
          system(NAMESPACES_LIST_COMMAND).tap do |result|
            result || exit(1)
          end
        end
        # :nocov:

        def namespaces
          namespaces_list.split("\n").map do |line|
            Namespace.new(line)
          end
        end

        def choices
          namespaces.map(&:to_choice)
        end

        Namespace = Struct.new(:name) do
          def to_choice
            {
              name: name,
              value: self
            }
          end

          def valid?
            name.present?
          end
        end
      end
    end
  end
end
