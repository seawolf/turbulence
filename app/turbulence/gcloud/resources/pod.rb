# frozen_string_literal: true

module Turbulence
  module GCloud
    module Resources
      # Google Cloud Pod
      class Pod
        def self.select(namespace) # rubocop:disable Metrics/MethodLength
          pods_list = `kubectl get pods -n #{namespace.name} -o jsonpath='{range .items[*]}{.metadata.name}{"\\n"}{end}' | grep foreground` || exit(1) # rubocop:disable Layout/LineLength
          pods = pods_list.split("\n").map do |line|
            Pod.new(line)
          end

          choices = pods.map do |p|
            {
              name: p.id,
              value: p
            }
          end

          raise "No Kubernetes pods in the #{namespace.name} namespace!" if choices.empty?

          pod = Menu.auto_select("Pods in the \"#{namespace.name}\" namespace:", choices, per_page: choices.length)
          Config.set(:pod_id, pod.id)

          pod
        end

        def self.from(id)
          Pod.new(id)
        end

        Pod = Struct.new(:id) do
          def valid?
            id.present?
          end
        end
      end
    end
  end
end
