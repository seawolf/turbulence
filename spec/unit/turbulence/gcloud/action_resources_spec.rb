# frozen_string_literal: true

describe Turbulence::GCloud::ActionResources do
  let(:instance) do
    Class.new do
      include Turbulence::GCloud::ActionResources
    end.new
  end

  describe '#project' do
    subject { instance.project }

    context 'when a valid project has been remembered' do
      let(:project) do
        instance_double(Turbulence::GCloud::Resources::Project::Project, id: 'project-id', valid?: true)
      end

      before do
        allow(Turbulence::Config).to receive(:get).with(:project_id).and_return(project.id)
        allow(Turbulence::GCloud::Resources::Project).to receive(:from).with(project.id).and_return(project)
      end

      it 'uses that project' do
        expect(subject).to eq(project)
      end

      context 'when previously-accessed' do
        before do
          allow(Turbulence::GCloud::Resources::Project).to receive(:select).once.and_return(project)

          subject
        end

        it 'is cached' do
          expect(Turbulence::Config).not_to receive(:get)
          expect(Turbulence::GCloud::Resources::Project).not_to receive(:select)

          expect(subject).to eq(project)
        end
      end
    end

    context 'when an invalid project has been remembered' do
      let(:project) do
        instance_double(Turbulence::GCloud::Resources::Project::Project, id: 'project-id', valid?: false)
      end

      before do
        allow(Turbulence::Config).to receive(:get).with(:project_id).and_return(project.id)
        allow(Turbulence::GCloud::Resources::Project).to receive(:from).with(project.id).and_return(project)
      end

      it 'asks which project should be used' do
        expect(Turbulence::GCloud::Resources::Project).to receive(:select).once.and_return(project)

        expect(subject).to eq(project)
      end
    end

    context 'when a project has not been remembered' do
      let(:project) { instance_double(Turbulence::GCloud::Resources::Project::Project, valid?: true) }

      before do
        allow(Turbulence::Config).to receive(:get).with(:project_id).and_return(nil)
      end

      it 'asks which project should be used' do
        expect(Turbulence::GCloud::Resources::Project).to receive(:select).and_return(project)

        expect(subject).to eq(project)
      end
    end
  end

  describe '#cluster' do
    subject { instance.cluster }

    let(:project) { instance_double(Turbulence::GCloud::Resources::Project) }

    before do
      allow(instance).to receive(:project).and_return(project)
    end

    context 'when a valid cluster has been remembered' do
      let(:cluster) do
        instance_double(Turbulence::GCloud::Resources::Cluster::Cluster, name: 'cluster-name',
                                                                         region: 'cluster-region', valid?: true)
      end

      before do
        allow(Turbulence::Config).to receive(:get).with(:cluster_name).and_return(cluster.name)
        allow(Turbulence::Config).to receive(:get).with(:cluster_region).and_return(cluster.region)
        allow(Turbulence::GCloud::Resources::Cluster).to receive(:from).with(cluster.name,
                                                                             cluster.region).and_return(cluster)
      end

      it 'uses that cluster' do
        expect(subject).to eq(cluster)
      end

      context 'when previously accessed' do
        before do
          allow(Turbulence::GCloud::Resources::Cluster).to receive(:select).with(project).once.and_return(cluster)

          subject
        end

        it 'is cached' do
          expect(Turbulence::Config).not_to receive(:get)
          expect(Turbulence::GCloud::Resources::Cluster).not_to receive(:select)

          expect(subject).to eq(cluster)
        end
      end
    end

    context 'when an invalid cluster has been remembered' do
      let(:cluster) do
        instance_double(Turbulence::GCloud::Resources::Cluster::Cluster, name: 'cluster-name',
                                                                         region: 'cluster-region', valid?: false)
      end

      before do
        allow(Turbulence::Config).to receive(:get).with(:cluster_name).and_return(cluster.name)
        allow(Turbulence::Config).to receive(:get).with(:cluster_region).and_return(cluster.region)
        allow(Turbulence::GCloud::Resources::Cluster).to receive(:from).with(cluster.name,
                                                                             cluster.region).and_return(cluster)
      end

      it 'asks which cluster should be used' do
        expect(Turbulence::GCloud::Resources::Cluster).to receive(:select).with(project).once.and_return(cluster)

        expect(subject).to eq(cluster)
      end
    end

    context 'when a cluster has not been remembered' do
      let(:cluster) { instance_double(Turbulence::GCloud::Resources::Cluster::Cluster, valid?: true) }

      before do
        allow(Turbulence::Config).to receive(:get).with(:cluster_name).and_return(nil)
        allow(Turbulence::Config).to receive(:get).with(:cluster_region).and_return(nil)
      end

      it 'asks which cluster should be used' do
        expect(Turbulence::GCloud::Resources::Cluster).to receive(:select).with(project).once.and_return(cluster)

        expect(subject).to eq(cluster)
      end
    end
  end

  describe '#namespace' do
    subject { instance.namespace }

    let(:cluster) { instance_double(Turbulence::GCloud::Resources::Cluster) }

    before do
      allow(instance).to receive(:cluster).and_return(cluster)
    end

    context 'when a valid namespace has been remembered' do
      let(:namespace) do
        instance_double(Turbulence::GCloud::Resources::Namespace::Namespace, name: 'namespace-name', valid?: true)
      end

      before do
        allow(Turbulence::Config).to receive(:get).with(:namespace_name).and_return(namespace.name)
        allow(Turbulence::GCloud::Resources::Namespace).to receive(:from).with(namespace.name).and_return(namespace)
      end

      it 'uses that namespace' do
        expect(subject).to eq(namespace)
      end

      context 'when previously-accessed' do
        before do
          allow(Turbulence::GCloud::Resources::Namespace).to receive(:select).with(cluster).once.and_return(namespace)

          subject
        end

        it 'is cached' do
          expect(Turbulence::Config).not_to receive(:get)
          expect(Turbulence::GCloud::Resources::Namespace).not_to receive(:select)

          expect(subject).to eq(namespace)
        end
      end
    end

    context 'when an invalid namespace has been remembered' do
      let(:namespace) do
        instance_double(Turbulence::GCloud::Resources::Namespace::Namespace, name: 'namespace-name', valid?: false)
      end

      before do
        allow(Turbulence::Config).to receive(:get).with(:namespace_name).and_return(namespace.name)
        allow(Turbulence::GCloud::Resources::Namespace).to receive(:from).with(namespace.name).and_return(namespace)
      end

      it 'asks which namespace should be used' do
        expect(Turbulence::GCloud::Resources::Namespace).to receive(:select).with(cluster).once.and_return(namespace)

        expect(subject).to eq(namespace)
      end
    end

    context 'when a namespace has not been remembered' do
      let(:namespace) { instance_double(Turbulence::GCloud::Resources::Namespace::Namespace, valid?: true) }

      before do
        allow(Turbulence::Config).to receive(:get).with(:namespace_name).and_return(nil)
      end

      it 'asks which namespace should be used' do
        expect(Turbulence::GCloud::Resources::Namespace).to receive(:select).with(cluster).and_return(namespace)

        expect(subject).to eq(namespace)
      end
    end
  end

  describe '#pod' do
    subject { instance.pod }

    let(:pod) { instance_double(Turbulence::GCloud::Resources::Pod) }
    let(:namespace) { instance_double(Turbulence::GCloud::Resources::Namespace) }

    before do
      allow(instance).to receive(:namespace).and_return(namespace)
    end

    it 'asks which pod should be used' do
      expect(Turbulence::GCloud::Resources::Pod).to receive(:select).with(namespace).once.and_return(pod)

      expect(subject).to eq(pod)
    end

    context 'when previously-accessed' do
      before do
        allow(Turbulence::GCloud::Resources::Pod).to receive(:select).with(namespace).once.and_return(pod)

        subject
      end

      it 'is cached' do
        expect(Turbulence::GCloud::Resources::Pod).not_to receive(:select)

        expect(subject).to eq(pod)
      end
    end
  end

  describe '#deployment' do
    subject { instance.deployment }

    let(:deployment) { instance_double(Turbulence::GCloud::Resources::Deployment) }
    let(:namespace) { instance_double(Turbulence::GCloud::Resources::Namespace) }

    before do
      allow(instance).to receive(:namespace).and_return(namespace)
    end

    it 'asks which deployment should be used' do
      expect(Turbulence::GCloud::Resources::Deployment).to receive(:select).with(namespace).once.and_return(deployment)

      expect(subject).to eq(deployment)
    end

    context 'when previously-accessed' do
      before do
        allow(Turbulence::GCloud::Resources::Deployment).to receive(:select).with(namespace).once.and_return(deployment)

        subject
      end

      it 'is cached' do
        expect(Turbulence::GCloud::Resources::Deployment).not_to receive(:select)

        expect(subject).to eq(deployment)
      end
    end
  end

  describe '#container' do
    subject { instance.container }

    let(:container) { instance_double(Turbulence::GCloud::Resources::Container) }
    let(:namespace) { instance_double(Turbulence::GCloud::Resources::Namespace) }
    let(:pod) { instance_double(Turbulence::GCloud::Resources::Pod) }

    before do
      allow(instance).to receive_messages({
                                            namespace: namespace,
                                            pod: pod
                                          })
    end

    it 'asks which container should be used' do
      expect(Turbulence::GCloud::Resources::Container).to receive(:select).with(namespace,
                                                                                pod).once.and_return(container)

      expect(subject).to eq(container)
    end

    context 'when previously-accessed' do
      before do
        allow(Turbulence::GCloud::Resources::Container).to receive(:select).with(namespace,
                                                                                 pod).once.and_return(container)

        subject
      end

      it 'is cached' do
        expect(Turbulence::GCloud::Resources::Container).not_to receive(:select)

        expect(subject).to eq(container)
      end
    end
  end
end
