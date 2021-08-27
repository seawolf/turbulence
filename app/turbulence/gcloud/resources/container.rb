# frozen_string_literal: true

module Turbulence
  module GCloud
    module Resources
      # Google Cloud Container
      class Container
        def self.select(namespace, pod)
          new(namespace, pod).tap(&:fetch).container
        end

        def self.from(name)
          Container.new(name)
        end

        attr_reader :container

        def initialize(namespace, pod)
          @namespace = namespace
          @pod = pod
        end

        def fetch
          raise "No containers in the #{@pod.id} pod!" if choices.empty?

          @container = cached_container do
            Menu.auto_select("Containers in the \"#{@pod.id}\" pod:", choices, per_page: choices.length)
          end
        end

        private

        attr_reader :namespace, :pod
        attr_writer :container

        def cached_container
          container = self.cached_container = yield # rubocop:disable Lint/UselessAssignment
        end

        def cached_container=(container)
          Config.set(:container_name, container.name)
        end

        # :nocov:
        def containers_list_command
          "kubectl get pods -n #{namespace.name} #{pod.id} -o jsonpath='"\
            '{range .spec.containers[*]}{.name}'\
            '{"\n"}'\
            '{end}'\
            "'"
        end

        def containers_list
          `#{containers_list_command}`.tap do |result|
            result || exit(1)
          end
        end
        # :nocov:

        def containers
          containers_list.split("\n").map do |line|
            Container.new(line)
          end
        end

        def choices
          containers.map(&:to_choice)
        end

        Container = Struct.new(:name) do
          def to_choice
            {
              name: name,
              value: self
            }
          end

          # def valid?
          #   name.present?
          # end
        end
      end
    end
  end
end
