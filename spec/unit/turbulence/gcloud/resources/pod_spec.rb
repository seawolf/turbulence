# frozen_string_literal: true

describe Turbulence::GCloud::Resources::Pod do
  let(:instance) { described_class.new(namespace) }
  let(:namespace) { double(:namespace, name: 'my-namespace') }

  describe '.select' do
    subject { described_class.select(namespace) }

    let(:pod) { instance_double(described_class::Pod) }

    before do
      allow(described_class).to receive(:new).and_return(instance)
    end

    it 'returns a newly-fetched Pod object' do
      allow(instance).to receive(:fetch).once do
        instance.instance_variable_set('@pod', pod)
      end

      expect(subject).to eq(pod)
    end
  end

  describe '.from' do
    subject { described_class.from(pod_id) }

    let(:pod_id) { double(:pod_id) }

    it 'creates a Pod with the given attributes' do
      expect(subject).to have_attributes({ id: pod_id })
    end
  end

  describe '#fetch' do
    subject { instance.fetch }

    let(:pods_list) { %w[pod-1 pod-2 pod-3] }
    let(:pod) { described_class::Pod.new(pods_list.sample) }

    shared_examples 'fetching and selecting a pod' do
      before do
        allow(instance).to receive(:all_pods_list).and_return(pods_list.join("\n"))
        allow(Turbulence::Menu).to receive(:auto_select).and_return(pod)
      end

      it 'fetches a new Pod' do
        expect(instance).to receive(:all_pods_list).and_return(pods_list.join("\n"))

        subject
      end

      it('returns the selected Pod') { is_expected.to eq(pod) }

      it 'sets the selected Pod' do
        subject

        expect(instance.pod).to eq(pod)
      end
    end

    context 'without a pre-selected pod' do
      include_examples 'fetching and selecting a pod'
    end

    context 'with a pre-selected pod' do
      before do
        allow(Turbulence::Config).to receive(:get).with(:pod_id).and_return(pod.id)
      end

      include_examples 'fetching and selecting a pod'
    end
  end
end
