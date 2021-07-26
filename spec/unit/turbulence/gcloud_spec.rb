# frozen_string_literal: true

describe Turbulence::GCloud do
  describe '.go!' do
    subject { described_class.go! }

    let(:auth) { instance_double(Turbulence::GCloud::Auth, check!: true) }
    let(:action) { instance_double(Turbulence::GCloud::Action) }

    before do
      expect(Turbulence::GCloud::Auth).to receive(:new).and_return(auth)
      expect(Turbulence::GCloud::Action).to receive(:new).and_return(action)
    end

    context 'when a config file does not exist', :empty_config do
      it 'initialises the config' do
        expect(Turbulence::Config).to receive(:init_config!).once.and_return(123)

        subject
      end
    end

    context 'when an empty or otherwise invalid config file exists' do
      before do
        allow(Turbulence::GCloud::ConfigHelper).to receive(:init_config?).and_return(true)
      end

      it 'does initialises the config' do
        expect(Turbulence::Config).to receive(:init_config!).once

        subject
      end

      context 'when a valid config file exists' do
        before do
          allow(Turbulence::GCloud::ConfigHelper).to receive(:init_config?).and_return(false)
        end

        it 'does not initialise the config' do
          expect(Turbulence::Config).not_to receive(:init_config!)

          subject
        end
      end
    end
  end
end
