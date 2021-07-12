# frozen_string_literal: true

module Turbulence
  module GCloud
    # Authenticates with Google Cloud, and displays details on success
    class Auth
      AUTH_COMMAND = 'gcloud auth login'
      LIST_COMMAND = 'gcloud auth list 2> /dev/null | grep \\*'

      def initialize
        PROMPT.say("\n·  Authenticating with Google Cloud...")
        system(%{ (#{LIST_COMMAND}) || ((#{AUTH_COMMAND}) && (#{LIST_COMMAND})) }) || exit(1)

        Config.set(:last_auth, Time.now.to_i)
      end
    end
  end
end
