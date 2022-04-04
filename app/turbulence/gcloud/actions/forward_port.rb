# frozen_string_literal: true

module Turbulence
  module GCloud
    module Actions
      # Allows access to a pod's TCP port by forawrding onto Turbulence and Docker-Compose
      class ForwardPort
        ID = :forward_port
        NAME = 'Set-up Port Forwarding from a pod to the host'
        TURBULENCE_PORT = 25_683

        include ActionResources

        def run
          project
          cluster
          namespace
          pod
          pod_port

          PROMPT.ok("\nConnecting...\n")
          connect
        end

        private

        def connection
          "kubectl port-forward -n #{namespace.name} #{pod.id} --address 0.0.0.0 #{TURBULENCE_PORT}:#{pod_port}"
        end

        def connect
          system(connection)
        end

        def pod_port
          raise "No ports exposed by the #{pod.id} pod!" if pod_ports.list.empty?

          Menu.auto_select("Ports exposed by the the \"#{pod.id}\" pod:", pod_ports.choices,
                           per_page: pod_ports.list.length)
        end

        def pod_ports
          @pod_ports ||= PodPorts.new(namespace, pod)
        end
      end
    end
  end
end
