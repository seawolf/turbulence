# frozen_string_literal: true

describe Turbulence::GCloud::Resources::Project do
  let(:instance) { described_class.new }

  describe '.select' do
    subject { described_class.select }

    let(:project) { instance_double(described_class::Project) }

    before do
      allow(described_class).to receive(:new).and_return(instance)
    end

    it 'returns a newly-fetched Project object' do
      expect(instance).to receive(:fetch).once do
        instance.instance_variable_set('@project', project)
      end

      expect(subject).to eq(project)
    end
  end

  describe '.from' do
    subject { described_class.from(project_id) }

    let(:project_id) { double(:project_id) }

    it 'creates a Project with the given attributes' do
      expect(subject).to have_attributes({ id: project_id })
    end
  end

  describe '#fetch' do
    subject { instance.fetch }

    let(:projects_name_list) { ['My First Project', 'My Second Project', 'My Third Project'] }
    let(:projects_id_list) { %w[project-1 project-2 project-3] }
    let(:projects_list) { projects_id_list.zip(projects_name_list).map { |pair| pair.join(' ') } }

    let(:project) do
      id = projects_id_list.sample
      described_class::Project.new(id)
    end

    context 'without a pre-selected project' do
      before do
        allow(instance).to receive(:projects_list).and_return(projects_list.join("\n"))
        allow(instance).to receive(:activate).and_return(project)
        allow(Turbulence::Menu).to receive(:auto_select).and_return(project)
      end

      it 'fetches a new Project' do
        expect(instance).to receive(:projects_list).and_return(projects_list.join("\n"))

        subject
      end

      it 'activates the selected Project' do
        expect(instance).to receive(:activate).and_return(project)

        subject
      end

      it('returns the selected Project') { is_expected.to eq(project) }

      it 'sets the selected Project' do
        subject

        expect(instance.project).to eq(project)
      end
    end

    context 'with a pre-selected project' do
      before do
        allow(Turbulence::Config).to receive(:get).with(:project_id).and_return(project.id)
      end

      before do
        allow(instance).to receive(:activate).and_return(project)
        allow(Turbulence::Menu).to receive(:auto_select).and_return(project)
      end

      it 'does not ask to select a new Project' do
        expect(instance).not_to receive(:projects_list)

        subject
      end

      it 'activates the previously-selected Project' do
        expect(instance).to receive(:activate).and_return(project)

        subject
      end

      it('returns the selected Project') { is_expected.to eq(project) }

      it 'sets the selected Project' do
        subject

        expect(instance.project).to eq(project)
      end
    end
  end
end
