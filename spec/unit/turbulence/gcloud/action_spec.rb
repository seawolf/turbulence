# frozen_string_literal: true

describe Turbulence::GCloud::Action do
  let(:action) { action_adaptor.new }
  let(:action_adaptors) { [action_adaptor] }

  let(:action_adaptor) do
    klass = Class.new do
      def id; end

      def class_name
        self.class
      end
    end

    klass.const_set(:ID, 'action-id')
    klass.const_set(:NAME, 'action-name')

    klass
  end

  before do
    stub_const('Turbulence::GCloud::Actions::LIST', action_adaptors)
  end

  after do
    allow(Turbulence::Menu).to receive(:auto_select).and_return(action)

    subject
  end

  it 'displays the list of choices compatible with `TTY:Prompt::Choice`' do
    expect(Turbulence::Menu).to receive(:auto_select).with(
      a_kind_of(String),
      [
        {
          name: 'action-name',
          value: have_attributes(
            id: 'action-id',
            name: 'action-name',
            class_name: action_adaptor
          )
        }
      ],
      a_kind_of(Hash)
    ).and_return(action)
  end

  it 'remembers the choice' do
    expect(Turbulence::Config).to receive(:set).with(:action, action.id).once
  end

  it 'starts the selected choice' do
    expect(action_adaptor).to receive(:new).once.and_return(action)
  end
end
