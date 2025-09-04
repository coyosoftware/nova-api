RSpec.describe Nova::API::Resource::Invoice do
  before(:all) do
    Nova::API.configure do |config|
      config.subdomain = 'foobar'
      config.api_key = 'foo-bar'
    end
  end

  describe 'statuses' do
    subject { described_class::STATUS }

    it 'has the authorized mapped as 2' do
      expect(subject::AUTHORIZED).to eq(2)
    end

    it 'has the cancelled mapped as 3' do
      expect(subject::CANCELLED).to eq(3)
    end
  end

  describe 'types' do
    subject { described_class::TYPE }

    it 'has the product mapped as 0' do
      expect(subject::PRODUCT).to eq(0)
    end

    it 'has the service mapped as 1' do
      expect(subject::SERVICE).to eq(1)
    end

    it 'has the product refund mapped as 2' do
      expect(subject::PRODUCT_REFUND).to eq(2)
    end
  end

  describe 'attributes' do
    subject { described_class }

    it { is_expected.to have_attribute(:id, Dry::Types['coercible.integer'].optional) }
    it { is_expected.to have_attribute(:bill_id, Dry::Types['coercible.integer']) }
    it { is_expected.to have_attribute(:danfe_url, Dry::Types['coercible.string'].optional) }
    it { is_expected.to have_attribute(:key, Dry::Types['coercible.string'].optional) }
    it { is_expected.to have_attribute(:number, Dry::Types['coercible.string']) }
    it { is_expected.to have_attribute(:series, Dry::Types['coercible.string']) }
    it { is_expected.to have_attribute(:status, Dry::Types['coercible.integer']) }
    it { is_expected.to have_attribute(:type, Dry::Types['coercible.integer']) }
    it { is_expected.to have_attribute(:url, Dry::Types['coercible.string'].optional) }
    it { is_expected.to have_attribute(:xml_url, Dry::Types['coercible.string'].optional) }
  end
end
