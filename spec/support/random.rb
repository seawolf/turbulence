# frozen_string_literal: true

module RSpec
  module Turbulence
    require 'securerandom'

    module_function

    def random_string(length: nil)
      SecureRandom.alphanumeric(length)
    end
  end
end
