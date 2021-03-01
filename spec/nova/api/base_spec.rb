RSpec.describe Nova::API::Base do
  describe '.endpoint' do
    it 'raises the endpoint not configured error' do
      expect { described_class.endpoint }.to raise_error(Nova::API::EndpointNotConfiguredError, 'Each class must implement its own endpoint')
    end
  end

  describe '.base_url' do
    context 'when the subdomain is not present' do
      it 'raises the missing subdomain error' do
        expect { described_class.base_url }.to raise_error(Nova::API::MissingSubdomainError, 'The subdomain must be informed')
      end
    end

    context 'when the subdomain is present' do
      before { Nova::API.configure { |config| config.subdomain = 'foo' } }

      it 'returns the api schema with subdomain and host' do
        expect(described_class.base_url).to eq("#{Nova::API::Base::SCHEME}://#{Nova::API.configuration.subdomain}.#{Nova::API::Base::HOST}")
      end
    end
  end

  describe '#endpoint' do
    it 'raises the endpoint not configured error' do
      expect { described_class.new.endpoint }.to raise_error(Nova::API::EndpointNotConfiguredError, 'Each class must implement its own endpoint')
    end
  end
end
