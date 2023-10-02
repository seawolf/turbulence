# frozen_string_literal: true

require 'spec_helper'

describe Turbulence::MessageBox do
  describe '.warning' do
    subject { described_class.warning(message) }

    let(:message) { 'Hello World!' }
    let(:style) do
      {
        fg: :white,
        bg: :red,
        border: {
          fg: :white,
          bg: :red
        }

      }
    end

    it 'prints an appropriately-styled warning message', :silent_output do
      expect(TTY::Box).to receive(:warn).with(message, style: style)

      subject
    end
  end
end
