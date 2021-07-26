# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:each, :silent_output) do
    allow($stdout).to receive(:write)
  end

  config.before(:each, :silent_prompts) do
    allow(Turbulence::Menu::PROMPT).to receive(:say)
  end
end
