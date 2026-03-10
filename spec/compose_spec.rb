# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
RSpec.describe Compose do
  before { described_class.instance_variable_set(:@ports, nil) }

  it 'has a version number' do
    expect(described_class::VERSION).not_to be nil
  end

  let(:ports) do
    {
      'mysql' => { '3306' => '3306' },
      'opensearch' => { '9200' => '9200', '9600' => '9600' },
      'redis' => { '6379' => '6379' }
    }
  end

  describe '::enabled?' do
    context 'when docker is not found on the filesystem' do
      before { allow(described_class).to receive(:docker).and_return nil }

      it 'returns false' do
        expect(described_class.enabled?).to be false
      end
    end

    context 'when docker is found on the filesystem' do
      before { allow(described_class).to receive(:docker).and_return '/usr/local/bin/docker' }

      it 'returns true' do
        expect(described_class.enabled?).to be true
      end
    end
  end

  describe '::ports' do
    before do
      allow(described_class).to receive(:execute)
        .with(:ps, '--format', 'json')
        .and_return([
          {
            Service: 'mysql',
            Publishers: [
              { TargetPort: 3306, PublishedPort: 3306 }
            ]
          },
          {
            Service: 'opensearch',
            Publishers: [
              { TargetPort: 9200, PublishedPort: 9200 },
              { TargetPort: 9600, PublishedPort: 9600 }
            ]
          },
          {
            Service: 'redis',
            Publishers: [
              { TargetPort: 6379, PublishedPort: 6379 }
            ]
          }
        ].map(&:to_json).join("\n"))
    end

    context 'when enabled' do
      before { allow(described_class).to receive(:enabled?).and_return true }

      it 'returns a map of port mappings' do
        expect(described_class.ports).to eq ports
      end
    end

    context 'when disabled' do
      before { allow(described_class).to receive(:enabled?).and_return false }

      it 'returns an empty hash' do
        expect(described_class.ports.empty?).to be true
      end
    end
  end

  describe '::port' do
    context 'when disabled' do
      before { allow(described_class).to receive(:enabled?).and_return false }

      it 'returns nil without template' do
        expect(described_class.port(:service, 1111)).to be_nil
      end

      it 'returns nil with template' do
        expect(described_class.port(:service, 1111, '%s')).to be_nil
      end
    end

    context 'when enabled' do
      before { allow(described_class).to receive(:ports).and_return ports }

      it 'returns the port' do
        expect(described_class.port(:mysql, 3306)).to eq '3306'
      end

      it 'returns the evaluated template' do
        expect(described_class.port(:redis, 6379, 'redis://localhost:%s')).to eq 'redis://localhost:6379'
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
