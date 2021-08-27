# frozen_string_literal: true

describe Turbulence::GCloud::Actions::RestartDeployment do
  let(:instance) { described_class.new }

  let(:project) { instance_double(Turbulence::GCloud::Resources::Project::Project, id: 'my-project') }
  let(:cluster) { instance_double(Turbulence::GCloud::Resources::Cluster::Cluster, name: 'my-cluster') }
  let(:namespace) { instance_double(Turbulence::GCloud::Resources::Namespace::Namespace, name: 'my-namespace') }
  let(:deployment) { instance_double(Turbulence::GCloud::Resources::Deployment::Deployment, name: 'my-deployment') }
  let(:connection) { 'kubectl rollout restart -n my-namespace deployment/my-deployment' }

  before do
    allow(Turbulence::Menu::PROMPT).to receive(:ok)

    allow(instance).to receive_messages(
      project: project,
      cluster: cluster,
      namespace: namespace,
      deployment: deployment,
      system: true
    )
  end

  describe '#run' do
    subject do
      instance.run
    end

    after do
      subject
    end

    it 'runs the command wrapped in whatever `kubectl` needs to get there' do
      expect(instance).to receive(:system).once.with(connection)
    end
  end
end
