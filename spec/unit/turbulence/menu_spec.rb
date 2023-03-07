# frozen_string_literal: true

require 'spec_helper'

describe Turbulence::Menu do
  it 'defines a menu-ish constant' do # rubocop:disable RSpec/MultipleExpectations
    expect(described_class::PROMPT).to be_respond_to(:say)
    expect(described_class::PROMPT).to be_respond_to(:ok)
    expect(described_class::PROMPT).to be_respond_to(:error)
    expect(described_class::PROMPT).to be_respond_to(:select)
  end

  describe '.auto_select', :silent_output do
    subject { described_class.auto_select(question, choices, **options) }

    let(:question) { 'Please Choose:' }
    let(:options) { {} }

    context 'when given a list of choices' do
      let(:choices) { %w[First Second Third] }

      it 'asks which choice to choose' do
        expect(described_class::PROMPT).to receive(:select)
          .with(question, choices, a_kind_of(Hash))

        subject
      end
    end

    context 'when given a list of one choice' do
      let(:choices) { %w[First] }

      it('tells the Menu to auto-select the only available option') { is_expected.to eq('First') }
    end

    context 'when given an empty list of choices' do
      let(:choices) { [] }

      it('continues with an empty answer') { is_expected.to be_nil }

      context 'when asking a question that requires an answer' do
        let(:options) { { exit_on_error: true } }

        it('aborts') { is_expected.to eq(RSpec::Turbulence::SystemExit) }
      end
    end
  end
end
