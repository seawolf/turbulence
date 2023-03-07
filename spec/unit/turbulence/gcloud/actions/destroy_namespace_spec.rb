# frozen_string_literal: true

describe Turbulence::GCloud::Actions::DestroyNamespace do
  let(:instance) { described_class.new }

  let(:project) { instance_double(Turbulence::GCloud::Resources::Project::Project, id: 'my-project') }
  let(:cluster) { instance_double(Turbulence::GCloud::Resources::Cluster::Cluster, name: 'my-cluster') }
  let(:namespace) { instance_double(Turbulence::GCloud::Resources::Namespace::Namespace, name: 'my-namespace') }
  let(:connection) { 'kubectl delete namespace my-namespace' }
  let(:confirmed) { true }

  before do
    allow(Turbulence::Menu::PROMPT).to receive(:ok)

    allow(instance).to receive_messages(
      project: project,
      cluster: cluster,
      namespace: namespace,
      confirm: confirmed,
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

    context 'when the action is confirmed' do
      it 'runs the command wrapped in whatever `kubectl` needs to get there' do
        expect(instance).to receive(:system).once.with(connection)
      end
    end

    context 'when the action is aborted' do
      let(:confirmed) { false }

      it 'does not run any command' do
        expect(instance).not_to receive(:system).with(connection)
      end
    end
  end
end
