# frozen_string_literal: true

describe Turbulence::GCloud::Actions::ForwardPort::PodPorts do
  let(:instance) { described_class.new(namespace, pod) }

  let(:namespace) { instance_double(Turbulence::GCloud::Resources::Namespace::Namespace, name: 'my-namespace') }
  let(:pod) { instance_double(Turbulence::GCloud::Resources::Pod::Pod, id: 'my-pod') }
  let(:connection) { 'kubectl get pod -n my-namespace my-pod --template' }

  before do
    allow(instance).to receive_messages(
      namespace: namespace,
      pod: pod,
      connect: "80\n8080\n"
    )
  end

  describe '#list' do
    subject do
      instance.list
    end

    after do
      subject
    end

    it 'runs the command wrapped in whatever `kubectl` needs to get there' do
      expect(instance).to receive(:connect).once
    end

    it 'connects with the expected command' do
      expect(instance.send(:connection)).to start_with(connection)
    end

    it('lists the exposed ports') { is_expected.to eq(%w[80 8080]) }
  end

  describe '#choices' do
    subject { instance.choices }

    it 'lists the exposed ports as menu items' do
      expect(subject).to eq([
                              {
                                name: '80',
                                value: '80'
                              },
                              {
                                name: '8080',
                                value: '8080'
                              }
                            ])
    end
  end
end
