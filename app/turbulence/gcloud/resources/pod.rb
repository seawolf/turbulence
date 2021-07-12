# frozen_string_literal: true

module Turbulence
  module GCloud
    module Resources
      # Google Cloud Pod
      class Pod
        def initialize # rubocop:disable Metrics/MethodLength
          namespace_name = Config.get(:namespace_name) || get_k8s_namespace

          pods_list = `kubectl get pods -n #{namespace_name} -o jsonpath='{range .items[*]}{.metadata.name}{"\\n"}{end}' | grep foreground` || exit(1) # rubocop:disable Metrics/LineLength
          pods = pods_list.split("\n").map do |line|
            Pod.new(line)
          end

          choices = pods.map do |pod|
            {
              name: pod.id,
              value: pod
            }
          end

          raise "No Kubernetes pods in the #{namespace_name} namespace!" if choices.empty?

          pod = Menu.auto_select("Pods in the \"#{namespace_name}\" namespace:", choices, per_page: choices.length)
          Config.set(:pod_id, pod.id)
        end

        Pod = Struct.new(:id)
      end
    end
  end
end
