# frozen_string_literal: true

describe Turbulence::GCloud::ConfigHelper do
  describe '.init_config?', :silent_prompts do
    subject { described_class.init_config? }

    let(:project_data) do
      double(:project_data, {
               id: 'my-project', name: 'My Project'
             })
    end

    let(:namespace_data) do
      double(:namespace_data, {
               name: 'my-namespace'
             })
    end

    let(:cluster_data) do
      double(:cluster_data, {
               name: 'My Cluster', region: 'my-cluster-region'
             })
    end

    before do
      allow(Turbulence::Config).to receive(:get).with(:project_id).and_return(project_data.id)
      allow(Turbulence::Config).to receive(:get).with(:namespace_name).and_return(namespace_data.name)
      allow(Turbulence::Config).to receive(:get).with(:cluster_name).and_return(cluster_data.name)
      allow(Turbulence::Config).to receive(:get).with(:cluster_region).and_return(cluster_data.region)
    end

    context 'when all resources from a previous run are found' do
      before do
        allow(Turbulence::Menu).to receive(:auto_select).once
      end

      it 'confirms the previous selection' do
        project = 'project: my-project'
        cluster = 'cluster: My Cluster.+my-cluster-region'
        namespace = 'namespace: my-namespace'

        expect(Turbulence::Menu::PROMPT).to receive(:say).with(/.+#{project}.+#{cluster}.+#{namespace}.+/m)
        subject
      end

      context 'when accepting previous values' do
        before do
          allow(Turbulence::Menu).to receive(:auto_select).once.and_return(false)
        end

        it('tells the caller there is no need to re-initialise the config') { is_expected.to be_falsey }
      end

      context 'when discarding previous values' do
        before do
          allow(Turbulence::Menu).to receive(:auto_select).once.and_return(true)
        end

        it('tells the caller to re-initialise the config') { is_expected.to be_truthy }
      end
    end

    context 'a project is missing' do
      let(:project_data) do
        double(:project_data, {
                 id: nil, name: nil
               })
      end

      it 'does not confirm the previous selection' do
        expect(Turbulence::Menu::PROMPT).not_to receive(:say)
        expect(Turbulence::Menu).not_to receive(:auto_select)

        subject
      end

      it('tells the caller to re-initialise the config') { is_expected.to be_truthy }
    end
  end
end
