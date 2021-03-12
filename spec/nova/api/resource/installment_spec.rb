RSpec.describe Nova::API::Resource::Installment do
  before(:all) do
    Nova::API.configure do |config|
      config.subdomain = 'foobar'
      config.api_key = 'foo-bar'
    end
  end

  describe 'attributes' do
    subject { described_class }

    it { is_expected.to have_attribute(:id, Dry::Types['coercible.integer'].optional) }
    it { is_expected.to have_attribute(:due_date, Dry::Types['coercible.string'].constrained(format: described_class::DATE_REGEX)) }
    it { is_expected.to have_attribute(:gross_value, Dry::Types['coercible.float'].optional) }
    it { is_expected.to have_attribute(:number, Dry::Types['coercible.integer']) }
    it { is_expected.to have_attribute(:value, Dry::Types['coercible.float']) }
  end

  describe '.endpoint' do
    it 'returns the bill endpoint' do
      expect(described_class.endpoint).to eq('/api/installments')
    end
  end
end
