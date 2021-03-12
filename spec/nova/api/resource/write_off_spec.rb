RSpec.describe Nova::API::Resource::WriteOff do
  before(:all) do
    Nova::API.configure do |config|
      config.subdomain = 'foobar'
      config.api_key = 'foo-bar'
    end
  end

  describe 'attributes' do
    subject { described_class }

    it { is_expected.to have_attribute(:date, Dry::Types['coercible.string'].constrained(format: described_class::DATE_REGEX).optional) }
    it { is_expected.to have_attribute(:value, Dry::Types['coercible.float'].optional) }
    it { is_expected.to have_attribute(:financial_account, Nova::API::Resource::FinancialAccount.optional) }
    it { is_expected.to have_attribute(:third_party, Nova::API::Resource::ThirdParty.optional) }
  end
end
