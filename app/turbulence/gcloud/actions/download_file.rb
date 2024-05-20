# frozen_string_literal: true

module Turbulence
  module GCloud
    module Actions
      # Downlaods a file from a pod
      class DownloadFile
        ID = :download_file
        NAME = 'Download a file from a Pod to your computer'

        include ActionResources

        def run
          project
          cluster
          namespace
          pod
          container
          remote_file
          download_destination

          PROMPT.ok("\nConnecting...\n")
          download &&
            PROMPT.ok("\nThe file is now in the Downloads folder of your Turbulence installation.")
        end

        private

        attr_reader :remote_file_path, :remote_file_name

        def remote_file
          return @remote_file if defined?(@remote_file)

          @remote_file = PROMPT.ask('Full path and filename of remote file: (e.g. /tmp/my-file)', required: true)
          @remote_file_path = File.dirname(remote_file)
          @remote_file_name = File.basename(remote_file)

          @remote_file
        end

        def download_destination
          system('[ -d ./Downloads ] || mkdir Downloads')
        end

        def command
          "kubectl cp -n #{namespace.name} -c #{container.name} " \
            "#{pod.id}:#{remote_file} ./Downloads/#{remote_file_name}"
        end

        def download
          system(command)
        end
      end
    end
  end
end
