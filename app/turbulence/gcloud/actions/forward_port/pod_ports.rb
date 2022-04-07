# frozen_string_literal: true

module Turbulence
  module GCloud
    module Actions
      class ForwardPort
        # List of ports exposed by a Pod
        class PodPorts
          def initialize(namespace, pod)
            @namespace = namespace
            @pod = pod
          end

          def choices
            list.map do |choice|
              {
                name: choice,
                value: choice
              }
            end
          end

          def list
            ports.split("\n").compact
          end

          private

          attr_reader :namespace, :pod

          def ports
            return @ports if defined?(@ports)

            @ports = connect
          end

          # :nocov:
          def connect
            `#{connection}`
          end
          # :nocov:

          def connection
            "kubectl get pod -n #{namespace.name} #{pod.id} "\
                "--template='"\
                  '{{(index (index .spec.containers 0).ports 0).containerPort}}{{"\n"}}'\
                  "'"
          end
        end
      end
    end
  end
end
