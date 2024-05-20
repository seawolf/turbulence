# frozen_string_literal: true

describe Turbulence::GCloud::Actions::DownloadFile do
  let(:instance) { described_class.new }

  let(:project) { instance_double(Turbulence::GCloud::Resources::Project::Project, id: 'my-project') }
  let(:cluster) { instance_double(Turbulence::GCloud::Resources::Cluster::Cluster, name: 'my-cluster') }
  let(:namespace) { instance_double(Turbulence::GCloud::Resources::Namespace::Namespace, name: 'my-namespace') }
  let(:pod) { instance_double(Turbulence::GCloud::Resources::Pod::Pod, id: 'my-pod') }
  let(:container) { instance_double(Turbulence::GCloud::Resources::Container::Container, name: 'my-container') }
  let(:command) { 'kubectl cp -n my-namespace -c my-container my-pod:/usr/src/some-file.ext ./Downloads/some-file.ext' }

  before do
    allow(Turbulence::Menu::PROMPT).to receive_messages(
      ask: '/usr/src/some-file.ext',
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

    it 'prepares the local download location' do
      expect(instance).to receive(:system)
        .with(a_string_matching(' -d ./Downloads ')).once
    end

    it 'runs the command wrapped in whatever `kubectl` needs to get there' do
      expect(instance).to receive(:system)
        .with(command).once
    end

    it 'asks what file should be downloaded' do
      expect(Turbulence::Menu::PROMPT).to receive(:ask).once.with(
        'Full path and filename of remote file: (e.g. /tmp/my-file)',
        required: true
      ).and_return('/usr/src/some-file.ext')
    end

    context 'when the download fails' do
      before do
        allow(instance).to receive(:system).with(command).and_return(false)
      end

      it 'does not confirm the download (leaving the output)' do
        expect(Turbulence::Menu::PROMPT).not_to receive(:ok)
          .with(a_string_matching('The file is now in the Downloads folder'))
      end
    end
  end
end
