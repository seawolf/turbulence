# frozen_string_literal: true

module RSpec
  module Turbulence
    TEST_CONFIG_FILE = './spec/support/config.yml'
  end
end

RSpec.configure do |config|
  config.before do |test|
    stub_const('::Turbulence::Config::CONFIG_FILE', RSpec::Turbulence::TEST_CONFIG_FILE)

    unless test.metadata[:empty_config]
      sample_contents = File.read("#{RSpec::Turbulence::TEST_CONFIG_FILE}.example")
      File.write(RSpec::Turbulence::TEST_CONFIG_FILE, sample_contents)
    end
  end

  config.after(:all) do
    FileUtils.rm_f(RSpec::Turbulence::TEST_CONFIG_FILE)
  end
end
