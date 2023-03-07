# frozen_string_literal: true

describe Turbulence::GCloud::Resources::Deployment do
  let(:instance) { described_class.new(namespace) }
  let(:namespace) { instance_double(Turbulence::GCloud::Resources::Namespace::Namespace, name: 'my-namespace') }

  describe '.select' do
    subject { described_class.select(namespace) }

    let(:deployment) { instance_double(described_class::Deployment) }

    before do
      allow(described_class).to receive(:new).and_return(instance)
    end

    it 'returns a newly-fetched Deployment object' do
      allow(instance).to receive(:fetch).once do
        instance.instance_variable_set('@deployment', deployment)
      end

      expect(subject).to eq(deployment)
    end
  end

  describe '.from' do
    subject { described_class.from(deployment_name) }

    let(:deployment_name) { object_double(String, :deployment_name) }

    it 'creates a Deployment with the given attributes' do
      expect(subject).to have_attributes({ name: deployment_name })
    end
  end

  describe '#fetch' do
    subject { instance.fetch }

    let(:deployments_list) { %w[deployment-1 deployment-2 deployment-3] }
    let(:deployment) { described_class::Deployment.new(deployments_list.sample) }

    shared_examples 'fetching and selecting a deployment' do
      before do
        allow(instance).to receive(:deployments_list).and_return(deployments_list.join("\n"))
        allow(Turbulence::Menu).to receive(:auto_select).and_return(deployment)
      end

      it 'fetches a new Deployment' do
        expect(instance).to receive(:deployments_list)

        subject
      end

      it('returns the selected Deployment') { is_expected.to eq(deployment) }

      it 'sets the selected Deployment' do
        subject

        expect(instance.deployment).to eq(deployment)
      end
    end

    context 'without a pre-selected deployment' do
      include_examples 'fetching and selecting a deployment'
    end

    context 'with a pre-selected deployment' do
      before do
        allow(Turbulence::Config).to receive(:get).with(:deployment_name).and_return(deployment.name)
      end

      include_examples 'fetching and selecting a deployment'
    end
  end
end
