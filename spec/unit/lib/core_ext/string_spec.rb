# frozen_string_literal: true

require 'spec_helper'

describe String do
  describe '#present?' do
    context 'when populated' do
      subject { 'Hello' }

      it { is_expected.to be_present }
    end

    context 'when populated and padded' do
      subject { ' Hello  ' }

      it { is_expected.to be_present }
    end

    context 'when empty' do
      subject { '' }

      it { is_expected.not_to be_present }
    end

    context 'when padding-only' do
      subject { ' ' }

      it { is_expected.not_to be_present }
    end
  end
end
