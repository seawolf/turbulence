# frozen_string_literal: true

describe Turbulence::GCloud::Actions::TailLogsSingleContainer do
  let(:instance) { described_class.new }

  let(:project) { instance_double(Turbulence::GCloud::Resources::Project::Project, id: 'my-project') }
  let(:cluster) { instance_double(Turbulence::GCloud::Resources::Cluster::Cluster, name: 'my-cluster') }
  let(:namespace) { instance_double(Turbulence::GCloud::Resources::Namespace::Namespace, name: 'my-namespace') }
  let(:container) { instance_double(Turbulence::GCloud::Resources::Container::Container, name: 'my-container') }
  let(:pod) { instance_double(Turbulence::GCloud::Resources::Pod::Pod, id: 'my-pod') }
  let(:connection) { 'kubectl logs -f my-pod -n my-namespace -c my-container' }

  before do
    allow(Turbulence::Menu::PROMPT).to receive(:ok)

    allow(instance).to receive_messages(
      project: project,
      cluster: cluster,
      namespace: namespace,
      container: container,
      pod: pod,
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
