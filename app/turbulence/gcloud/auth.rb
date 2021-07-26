# frozen_string_literal: true

module Turbulence
  module GCloud
    # Authenticates with Google Cloud, and displays details on success
    class Auth
      AUTH_COMMAND = 'gcloud auth login'
      LIST_COMMAND = 'gcloud auth list 2> /dev/null | grep \\*'

      def check!
        PROMPT.say("\n·  Authenticating with Google Cloud...")

        if connect
          Config.set(:last_auth, Time.now.to_i)
        else
          _exit
        end
      end

      private

      def connection
        "(#{LIST_COMMAND}) || ((#{AUTH_COMMAND}) && (#{LIST_COMMAND}))"
      end

      def connect
        system(connection)
      end

      def _exit
        return RSpec::Turbulence::SystemExit if defined?(RSpec)

        # :nocov:
        exit(1)
        # :nocov:
      end
    end
  end
end
