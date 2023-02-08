# frozen_string_literal: true

require 'spec_helper'

describe Turbulence::MessageBox do
  describe '.warning' do
    subject { described_class.warning(message) }

    let(:message) { 'Hello World!' }

    it 'prints an appropriately-styled warning message', silent_output: true do
      expect(TTY::Box).to receive(:warn).with('Hello World!', style: {
                                                fg: :white,
                                                bg: :red,
                                                border: {
                                                  fg: :white,
                                                  bg: :red
                                                }
                                              })

      subject
    end
  end
end
