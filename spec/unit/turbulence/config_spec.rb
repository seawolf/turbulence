# frozen_string_literal: true

require 'spec_helper'

describe Turbulence::Config do
  describe '.config' do
    subject do
      described_class.config
    end

    it 'loads the config file in to a Hash' do
      expect(subject).to eq({ 'hello' => 'world' })
    end

    context 'when the file does not exist' do
      let(:the_error) { Errno::ENOENT.new('Nope!') }

      before do
        expect(File).to receive(:read).with(described_class::CONFIG_FILE).and_raise(the_error)
      end

      it 'fails' do
        expect { subject }.to raise_error(the_error)
      end
    end

    context 'when the file is invalid' do
      before do
        expect(File).to receive(:read).with(described_class::CONFIG_FILE).and_return('!!!!!')
      end

      it('returns an empty Hash') { is_expected.to eq({}) }
    end
  end

  describe '.config!' do
    subject { described_class.config!(data) }

    context 'when given serialisable data' do
      let(:data) { { one: 1 } }

      it 'writes the data to the config file' do
        subject

        new_file_contents = File.read(described_class::CONFIG_FILE)
        result = YAML.load(new_file_contents) # rubocop:disable Security/YAMLLoad
        expect(result).to eq(data)
      end
    end

    context 'when given unserialisable data' do
      let(:data) { Class.new }

      it 'fails' do
        expect { subject }.to raise_error(TypeError)
      end
    end
  end

  describe '.get' do
    subject { described_class.get(key) }

    let(:key) { RSpec::Turbulence.random_string }
    let(:value) { RSpec::Turbulence.random_string }

    before do
      data = { key => value }

      File.write(described_class::CONFIG_FILE, YAML.dump(data))
    end

    it('returns the value from the config') { is_expected.to eq(value) }
  end

  describe '.set' do
    subject { described_class.set(key, value) }

    let(:key) { RSpec::Turbulence.random_string }
    let(:value) { RSpec::Turbulence.random_string }

    before do
      File.write(described_class::CONFIG_FILE, YAML.dump({}))
    end

    it 'writes the value to the config' do
      subject

      file_contents = File.read(described_class::CONFIG_FILE)
      result = YAML.load(file_contents) # rubocop:disable Security/YAMLLoad
      expect(result[key]).to eq(value)
    end

    it('returns the value') { is_expected.to eq(value) }
  end

  describe 'init_config!' do
    subject { described_class.init_config! }

    before do
      File.delete described_class::CONFIG_FILE
    end

    it 'writes a new config file' do
      expect do
        subject
      end.to change {
               File.exist? described_class::CONFIG_FILE
             }.from(false).to(true)
    end
  end
end
