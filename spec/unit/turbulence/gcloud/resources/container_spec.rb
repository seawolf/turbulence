# frozen_string_literal: true

describe Turbulence::GCloud::Resources::Container do
  let(:instance) { described_class.new(namespace, pod) }
  let(:namespace) { double(:namespace, name: 'my-namespace') }
  let(:pod) { double(:pod, id: 'my-pod') }

  describe '.select' do
    subject { described_class.select(namespace, pod) }

    let(:container) { instance_double(described_class::Container) }

    before do
      allow(described_class).to receive(:new).and_return(instance)
    end

    it 'returns a newly-fetched Container object' do
      expect(instance).to receive(:fetch).once do
        instance.instance_variable_set('@container', container)
      end

      expect(subject).to eq(container)
    end
  end

  describe '.from' do
    subject { described_class.from(container_name) }

    let(:container_name) { double(:container_name) }

    it 'creates a Container with the given attributes' do
      expect(subject).to have_attributes({ name: container_name })
    end
  end

  describe '#fetch' do
    subject { instance.fetch }

    let(:containers_list) { %w[container-1 container-2 container-3] }
    let(:container) { described_class::Container.new(containers_list.sample) }

    shared_examples 'fetching and selecting a container' do
      before do
        allow(instance).to receive(:containers_list).and_return(containers_list.join("\n"))
        allow(Turbulence::Menu).to receive(:auto_select).and_return(container)
      end

      it 'fetches a new Container' do
        expect(instance).to receive(:containers_list).and_return(containers_list.join("\n"))

        subject
      end

      it('returns the selected Container') { is_expected.to eq(container) }

      it 'sets the selected Container' do
        subject

        expect(instance.container).to eq(container)
      end
    end

    context 'without having previously-selected a container' do
      include_examples 'fetching and selecting a container'
    end

    context 'having previously-selected a container' do
      before do
        allow(Turbulence::Config).to receive(:get).with(:container_name).and_return(container.name)
      end

      include_examples 'fetching and selecting a container'
    end
  end
end
