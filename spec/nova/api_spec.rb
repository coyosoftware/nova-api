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

  describe "#apportionments" do
    it 'returns the Nova::API::Resource::Apportionment class' do
      expect(Nova::API::Client.new.apportionments).to eq(Nova::API::Resource::Apportionment)
    end
  end

  describe "#apportionment_values" do
    it 'returns the Nova::API::Resource::ApportionmentValue class' do
      expect(Nova::API::Client.new.apportionment_values).to eq(Nova::API::Resource::ApportionmentValue)
    end
  end

  describe "#banks" do
    it 'returns the Nova::API::Resource::Bank class' do
      expect(Nova::API::Client.new.banks).to eq(Nova::API::Resource::Bank)
    end
  end

  describe "#cards" do
    it 'returns the Nova::API::Resource::Card class' do
      expect(Nova::API::Client.new.cards).to eq(Nova::API::Resource::Card)
    end
  end

  describe "#cashes" do
    it 'returns the Nova::API::Resource::Cash class' do
      expect(Nova::API::Client.new.cashes).to eq(Nova::API::Resource::Cash)
    end
  end

  describe "#companies" do
    it 'returns the Nova::API::Resource::Company class' do
      expect(Nova::API::Client.new.companies).to eq(Nova::API::Resource::Company)
    end
  end

  describe "#current_assets" do
    it 'returns the Nova::API::Resource::CurrentAsset class' do
      expect(Nova::API::Client.new.current_assets).to eq(Nova::API::Resource::CurrentAsset)
    end
  end

  describe "#financial_accounts" do
    it 'returns the Nova::API::Resource::FinancialAccount class' do
      expect(Nova::API::Client.new.financial_accounts).to eq(Nova::API::Resource::FinancialAccount)
    end
  end

  describe "#payables" do
    it 'returns the Nova::API::Resource::Payable class' do
      expect(Nova::API::Client.new.payables).to eq(Nova::API::Resource::Payable)
    end
  end

  describe "#permissions" do
    it 'returns the Nova::API::Resource::Permission class' do
      expect(Nova::API::Client.new.permissions).to eq(Nova::API::Resource::Permission)
    end
  end

  describe "#receivables" do
    it 'returns the Nova::API::Resource::Receivable class' do
      expect(Nova::API::Client.new.receivables).to eq(Nova::API::Resource::Receivable)
    end
  end

  describe "#third_parties" do
    it 'returns the Nova::API::Resource::ThirdParty class' do
      expect(Nova::API::Client.new.third_parties).to eq(Nova::API::Resource::ThirdParty)
    end
  end
end
