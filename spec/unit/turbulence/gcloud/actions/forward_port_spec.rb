# frozen_string_literal: true

describe Turbulence::GCloud::Actions::ForwardPort do
  let(:instance) { described_class.new }

  let(:project) { instance_double(Turbulence::GCloud::Resources::Project::Project, id: 'my-project') }
  let(:cluster) { instance_double(Turbulence::GCloud::Resources::Cluster::Cluster, name: 'my-cluster') }
  let(:namespace) { instance_double(Turbulence::GCloud::Resources::Namespace::Namespace, name: 'my-namespace') }
  let(:pod) { instance_double(Turbulence::GCloud::Resources::Pod::Pod, id: 'my-pod') }
  let(:connection) { 'kubectl port-forward -n my-namespace my-pod --address 0.0.0.0 25683:8080' }

  before do
    allow(Turbulence::Menu::PROMPT).to receive_messages(
      select: project,
      ok: true
    )
    allow(instance).to receive_messages(
      project: project,
      cluster: cluster,
      namespace: namespace,
      pod: pod,
      pod_port: '8080',
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
