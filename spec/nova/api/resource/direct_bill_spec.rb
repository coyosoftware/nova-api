RSpec.describe Nova::API::Resource::DirectBill do
  before(:all) do
    Nova::API.configure do |config|
      config.subdomain = 'foobar'
      config.api_key = 'foo-bar'
    end
  end

  describe 'attributes' do
    subject { described_class }

    it { is_expected.to have_attribute(:addition, Dry::Types['coercible.float'].optional) }
    it { is_expected.to have_attribute(:additional_information, Dry::Types['coercible.string'].optional) }
    it { is_expected.to have_attribute(:apportionments, Dry::Types['strict.array'].of(Nova::API::Resource::Bill::Apportionment).optional) }

    context 'apportionments' do
      subject { Nova::API::Resource::Bill::Apportionment }

      it { is_expected.to have_attribute(:apportionment_value_ids, Dry::Types['strict.array'].of(Dry::Types['coercible.integer'].optional)) }
      it { is_expected.to have_attribute(:value, Dry::Types['coercible.float']) }
    end

    it { is_expected.to have_attribute(:attachments, Dry::Types['strict.array'].of(Dry::Types['coercible.string']).optional) }
    it { is_expected.to have_attribute(:company_id, Dry::Types['coercible.integer']) }
    it { is_expected.to have_attribute(:date, Dry::Types['coercible.string'].constrained(format: described_class::DATE_REGEX)) }
    it { is_expected.to have_attribute(:discount, Dry::Types['coercible.float'].optional) }
    it { is_expected.to have_attribute(:document_number, Dry::Types['coercible.string']) }
    it { is_expected.to have_attribute(:document_type, Dry::Types['coercible.integer']) }
    it { is_expected.to have_attribute(:financial_accounts, Dry::Types['strict.array'].of(Nova::API::Resource::Bill::FinancialAccount).optional) }

    context 'financial accounts' do
      subject { Nova::API::Resource::Bill::FinancialAccount }

      it { is_expected.to have_attribute(:financial_account_id, Dry::Types['coercible.integer']) }
      it { is_expected.to have_attribute(:value, Dry::Types['coercible.float']) }
    end

    it { is_expected.to have_attribute(:first_due_date, Dry::Types['coercible.string'].constrained(format: described_class::DATE_REGEX)) }
    it { is_expected.to have_attribute(:identifier, Dry::Types['coercible.string'].optional) }
    it { is_expected.to have_attribute(:installments, Dry::Types['strict.array'].of(Nova::API::Resource::DirectBill::Installment).optional) }

    context 'installments' do
      subject { described_class::Installment }

      it { is_expected.to have_attribute(:current_asset_id, Dry::Types['coercible.integer']) }
      it { is_expected.to have_attribute(:document_number, Dry::Types['coercible.string']) }
      it { is_expected.to have_attribute(:document_type, Dry::Types['coercible.integer']) }
      it { is_expected.to have_attribute(:due_date, Dry::Types['coercible.string'].constrained(format: described_class::DATE_REGEX)) }
      it { is_expected.to have_attribute(:value, Dry::Types['coercible.float']) }
    end

    it { is_expected.to have_attribute(:third_party_id, Dry::Types['coercible.integer']) }
    it { is_expected.to have_attribute(:total_value, Dry::Types['coercible.float']) }
  end

  describe '.endpoint' do
    it 'returns nothing' do
      expect(described_class.endpoint).to be_nil
    end
  end
end
