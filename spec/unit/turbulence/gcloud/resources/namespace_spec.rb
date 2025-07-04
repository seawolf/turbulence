# frozen_string_literal: true

describe Turbulence::GCloud::Resources::Namespace do
  let(:instance) { described_class.new(cluster) }
  let(:cluster) { instance_double(Turbulence::GCloud::Resources::Cluster::Cluster, name: 'my-cluster') }

  describe '.select' do
    subject { described_class.select(cluster) }

    let(:namespace) { instance_double(described_class::Namespace) }

    before do
      allow(described_class).to receive(:new).and_return(instance)
    end

    it 'returns a newly-fetched Namespace object' do
      allow(instance).to receive(:fetch).once do
        instance.instance_variable_set('@namespace', namespace)
      end

      expect(subject).to eq(namespace)
    end
  end

  describe '.from' do
    subject { described_class.from(namespace_name) }

    let(:namespace_name) { object_double(String, :namespace_name) }

    it 'creates a Namespace with the given attributes' do
      expect(subject).to have_attributes({ name: namespace_name })
    end
  end

  describe '#fetch' do
    subject { instance.fetch }

    let(:namespaces_list) { %w[namespace-1 namespace-2 namespace-3] }
    let(:namespace) { described_class::Namespace.new(namespaces_list.sample) }

    shared_examples 'fetching and selecting a namespace' do
      before do
        allow(instance).to receive(:namespaces_list).and_return(namespaces_list.join("\n"))
        allow(Turbulence::Menu).to receive(:auto_select).and_return(namespace)
      end

      it 'fetches a new Namespace' do
        expect(instance).to receive(:namespaces_list)

        subject
      end

      it('returns the selected Namespace') { is_expected.to eq(namespace) }

      it 'sets the selected Namespace' do
        subject

        expect(instance.namespace).to eq(namespace)
      end
    end

    context 'without a pre-selected namespace' do
      it_behaves_like 'fetching and selecting a namespace'
    end

    context 'with a pre-selected namespace' do
      before do
        allow(Turbulence::Config).to receive(:get).with(:namespace_name).and_return(namespace.name)
      end

      it_behaves_like 'fetching and selecting a namespace'
    end
  end
end
