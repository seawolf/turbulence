# frozen_string_literal: true

module RSpec
  module Turbulence
    class SystemExit < RuntimeError
      MESSAGE = 'This class is for testing methods that `exit()`. ' \
                'Example usage: `allow(subject).to recieve(:exit).and_return(RSpec::Turbulence::SystemExit)`'

      def message
        MESSAGE
      end
    end
  end
end
