# frozen_string_literal: true

describe Turbulence::GCloud::Actions::ConnectToContainer do
  let(:instance) { described_class.new }

  let(:project) { instance_double(Turbulence::GCloud::Resources::Project::Project, id: 'my-project') }
  let(:cluster) { instance_double(Turbulence::GCloud::Resources::Cluster::Cluster, name: 'my-cluster') }
  let(:namespace) { instance_double(Turbulence::GCloud::Resources::Namespace::Namespace, name: 'my-namespace') }
  let(:pod) { instance_double(Turbulence::GCloud::Resources::Pod::Pod, id: 'my-pod') }
  let(:container) { instance_double(Turbulence::GCloud::Resources::Container::Container, name: 'my-container') }
  let(:command) { 'my-command' }
  let(:connection) { 'kubectl exec -it my-pod -n my-namespace -c my-container -- my-command' }

  before do
    allow(Turbulence::Menu::PROMPT).to receive_messages(
      select: command,
      ask: command,
      ok: true
    )
    allow(instance).to receive_messages(
      project: project,
      cluster: cluster,
      namespace: namespace,
      pod: pod,
      container: container,
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

    it 'asks what command should be used upon connection' do
      expect(Turbulence::Menu::PROMPT).to receive(:select).once.with(
        a_kind_of(String),
        a_kind_of(Array),
        a_kind_of(Hash)
      )
    end

    context 'when selecting an empty command' do
      before do
        allow(Turbulence::Menu::PROMPT).to receive(:select).once.and_return(nil)
      end

      it 'requests a command to be run' do
        expect(Turbulence::Menu::PROMPT).to receive(:ask).once.with(
          a_kind_of(String),
          a_kind_of(Hash)
        )
      end
    end
  end
end
