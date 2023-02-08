# frozen_string_literal: true

module Turbulence
  module GCloud
    module Resources
      # Google Cloud Deployment
      class Deployment
        def self.select(namespace)
          new(namespace).tap(&:fetch).deployment
        end

        def self.from(name)
          Deployment.new(name)
        end

        attr_reader :deployment

        def initialize(namespace)
          @namespace = namespace
        end

        def fetch
          raise "No deployments in the #{namespace.name} namespace!" if choices.empty?

          @deployment = cached_deployment do
            Menu.auto_select("Deployments in the \"#{namespace.name}\" namespace:", choices,
                             per_page: choices.length)
          end
        end

        private

        attr_reader :namespace
        attr_writer :deployment

        def cached_deployment
          deployment = self.cached_deployment = yield # rubocop:disable Lint/UselessAssignment
        end

        def cached_deployment=(deployment)
          Config.set(:deployment_name, deployment.name)
        end

        # :nocov:
        def deployments_list_command
          "kubectl get deployments -n #{namespace.name} -o jsonpath='" \
            '{range .items[*]}' \
            '{.metadata.name}' \
            '{"\n"}' \
            '{end}' \
            "'"
        end

        def deployments_list
          `#{deployments_list_command}`.tap do |result|
            result || exit(1)
          end
        end
        # :nocov:

        def deployments
          deployments_list.split("\n").map do |line|
            Deployment.new(line)
          end
        end

        def choices
          deployments.map(&:to_choice)
        end

        Deployment = Struct.new(:name) do
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
