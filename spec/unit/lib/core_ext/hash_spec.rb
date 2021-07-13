# frozen_string_literal: true

require 'spec_helper'

describe Hash do
  describe '#present?' do
    context 'when populated' do
      subject { { hello: :world } }
      it { is_expected.to be_present }
    end

    context 'when populated with empty values ' do
      subject { { hello: nil } }
      it { is_expected.to be_present }
    end

    context 'when populated with empty keys and values' do
      subject { { nil => nil } }
      it { is_expected.to be_present }
    end

    context 'when empty' do
      subject { {} }
      it { is_expected.not_to be_present }
    end
  end
end
