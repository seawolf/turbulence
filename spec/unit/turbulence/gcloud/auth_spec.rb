# frozen_string_literal: true

require 'spec_helper'

describe Turbulence::GCloud::Auth do
  let(:instance) { described_class.new }

  describe '#check!', :silent_prompts do
    subject { instance.check! }

    let(:auth_successful) { false }

    before do
      # allow(instance).to receive(:connect).and_return(auth_successful)
      allow(instance).to receive(:system)
        .with(a_string_matching(/gcloud auth list.+||gcloud auth login.+&&.+gcloud auth list/))
        .and_return(auth_successful)
    end

    context 'when the authentication is unsuccessful' do
      it 'does not mark a successful authentication' do
        expect(Turbulence::Config).not_to receive(:set)

        subject
      end

      it 'aborts' do
        expect(instance).to receive(:_exit)

        subject
      end
    end

    context 'when the authentication is successful' do
      let(:auth_successful) { true }
      let(:the_time) { instance_double(Time, to_i: the_time_value) }
      let(:the_time_value) { instance_double(Integer) }

      before do
        allow(Time).to receive(:now).and_return(the_time)
      end

      it 'marks the last successful authentication' do
        expect(Turbulence::Config).to receive(:set).with(:last_auth, the_time_value)

        subject
      end
    end
  end
end
