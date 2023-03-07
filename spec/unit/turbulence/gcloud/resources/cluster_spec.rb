# frozen_string_literal: true

describe Turbulence::GCloud::Resources::Cluster do
  let(:instance) { described_class.new(project) }
  let(:project) { double(:project, id: 'my-project') }

  describe '.select' do
    subject { described_class.select(project) }

    let(:cluster) { instance_double(described_class::Cluster) }

    before do
      allow(described_class).to receive(:new).and_return(instance)
    end

    it 'returns a newly-fetched Cluster object' do
      allow(instance).to receive(:fetch).once do
        instance.instance_variable_set('@cluster', cluster)
      end

      expect(subject).to eq(cluster)
    end
  end

  describe '.from' do
    subject { described_class.from(cluster_name, cluster_region) }

    let(:cluster_name) { double(:cluster_name) }
    let(:cluster_region) { double(:cluster_region) }

    it 'creates a Cluster with the given attributes' do
      expect(subject).to have_attributes({ name: cluster_name, region: cluster_region })
    end
  end

  describe '#fetch' do
    subject { instance.fetch }

    let(:clusters_name_list) { %w[cluster-1 cluster-2 cluster-3] }
    let(:clusters_region_list) { %w[region-1 region-2 region-3] }
    let(:clusters_list) { clusters_name_list.zip(clusters_region_list).map { |pair| pair.join(' ') } }

    let(:cluster) do
      cluster_name, cluster_region = clusters_list.sample.to_s.split
      described_class::Cluster.new(cluster_name, cluster_region)
    end

    context 'without a pre-selected cluster' do
      before do
        allow(instance).to receive(:clusters_list).and_return(clusters_list.join("\n"))
        allow(instance).to receive(:activate).and_return(cluster)
        allow(Turbulence::Menu).to receive(:auto_select).and_return(cluster)
      end

      it 'fetches a new Cluster' do
        expect(instance).to receive(:clusters_list)

        subject
      end

      it 'activates the selected Cluster' do
        expect(instance).to receive(:activate)

        subject
      end

      it('returns the selected Cluster') { is_expected.to eq(cluster) }

      it 'sets the selected Cluster' do
        subject

        expect(instance.cluster).to eq(cluster)
      end

      context 'when the selected project has no clusters' do
        let(:clusters_list) { [] }

        it 'cannot continue' do
          expect { subject }.to raise_error(/No Kubernetes clusters in the my-project project/)
        end
      end
    end

    context 'with a pre-selected cluster' do
      before do
        allow(Turbulence::Config).to receive(:get).with(:cluster_name).and_return(cluster.name)
        allow(Turbulence::Config).to receive(:get).with(:cluster_region).and_return(cluster.region)

        allow(instance).to receive(:activate).and_return(cluster)
        allow(Turbulence::Menu).to receive(:auto_select).and_return(cluster)
      end

      it 'does not ask to select a new Cluster' do
        expect(instance).not_to receive(:clusters_list)

        subject
      end

      it 'activates the previously-selected Cluster' do
        expect(instance).to receive(:activate)

        subject
      end

      it('returns the selected Cluster') { is_expected.to eq(cluster) }

      it 'sets the selected Cluster' do
        subject

        expect(instance.cluster).to eq(cluster)
      end
    end
  end
end
