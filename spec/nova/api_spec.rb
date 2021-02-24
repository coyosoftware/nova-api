RSpec.describe Nova::API do
  it "has a version number" do
    expect(Nova::API::VERSION).not_to be_nil
  end

  describe '.configure' do
    it 'allows the configuration of the api key' do
      expect { described_class.configure { |config| config.api_key = 'foo-bar-baz' } }.to change(described_class.configuration, :api_key).to 'foo-bar-baz'
    end

    it 'allows the configuration of the subdomain' do
      expect { described_class.configure { |config| config.subdomain = 'foobarbaz' } }.to change(described_class.configuration, :subdomain).to 'foobarbaz'
    end
  end
end
