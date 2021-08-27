# frozen_string_literal: true

require 'spec_helper'

describe NilClass do
  subject { nil }

  describe '#present?' do
    it { is_expected.not_to be_present }
  end
end
