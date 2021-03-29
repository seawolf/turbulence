# frozen_string_literal: true

module RSpec
  module Turbulence
    TEST_CONFIG_FILE = './spec/support/config.yml'
  end
end

RSpec.configure do |config|
  config.before(:each) do
    stub_const('::Turbulence::Config::CONFIG_FILE', RSpec::Turbulence::TEST_CONFIG_FILE)

    sample_contents = File.read("#{RSpec::Turbulence::TEST_CONFIG_FILE}.example")
    File.write(RSpec::Turbulence::TEST_CONFIG_FILE, sample_contents)
  end

  config.after(:all) do
    File.delete(RSpec::Turbulence::TEST_CONFIG_FILE)
  end
end
