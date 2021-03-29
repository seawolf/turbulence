# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:each, :silent_output) do
    allow($stdout).to receive(:write)
  end
end
