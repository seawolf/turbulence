# frozen_string_literal: true

module Turbulence
  module GCloud
    module Actions
      # Destroy all resources in a namespace
      class DestroyNamespace
        ID = :destroy_namespace
        NAME = 'Destroy all resources in a namespace'

        include ActionResources

        def run
          project
          cluster
          namespace

          confirmation = confirm
          confirmation && destroy || bail_out

          confirmation
        end

        private

        def connection
          "kubectl delete namespace #{namespace.name}"
        end

        def connect
          system(connection)
        end

        def confirm
          Turbulence::MessageBox.warning([
            'This action is IRREVERSIBLE !',
            'All of the pods, containers, ingresses, etc. within the namespace will be permenantly destroyed.',
            'It may take some minutes, through which there is no opportunity to pause or abort.'
          ].join("\n\n"))

          PROMPT.select("Destroy the \"#{namespace.name}\" namespace?", {
                          No: false,
                          Yes: true
                        })
        end

        def destroy
          PROMPT.ok("\nDestroying...\n")
          connect
          PROMPT.ok("\nDestroyed.\n")
        end

        def bail_out
          PROMPT.ok("\nNamespace preserved.\n")
        end
      end
    end
  end
end
