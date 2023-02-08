# frozen_string_literal: true

module Turbulence
  module GCloud
    module Resources
      # Google Cloud Pod
      class Pod
        def self.select(namespace)
          new(namespace).tap(&:fetch).pod
        end

        def self.from(id)
          Pod.new(id)
        end

        attr_reader :pod

        def initialize(namespace = nil)
          @namespace = namespace
        end

        def fetch
          raise "No Kubernetes pods in the #{namespace.name} namespace!" if choices.empty?

          @pod = cached_pod do
            Menu.auto_select("Pods in the \"#{namespace.name}\" namespace:", choices, per_page: choices.length)
          end
        end

        private

        attr_reader :namespace
        attr_writer :pod

        def cached_pod
          pod = self.cached_pod = yield # rubocop:disable Lint/UselessAssignment
        end

        def cached_pod=(pod)
          Config.set(:pod_id, pod.id)
        end

        # :nocov:
        def pods_list_command
          "kubectl get pods -n #{namespace.name} -o jsonpath='" \
            '{range .items[*]}' \
            '{.metadata.name}' \
            '{"\n"}' \
            '{end}' \
            "'"
        end

        def all_pods_list
          `#{pods_list_command}`
        end

        def pods_list
          all_pods_list.split("\n").presence || exit(1)
        end
        # :nocov:

        def pods
          pods_list.map do |line|
            Pod.new(line)
          end
        end

        def choices
          pods.map(&:to_choice)
        end

        Pod = Struct.new(:id) do
          def to_choice
            {
              name: id,
              value: self
            }
          end

          # def valid?
          #   id.present?
          # end
        end
      end
    end
  end
end
