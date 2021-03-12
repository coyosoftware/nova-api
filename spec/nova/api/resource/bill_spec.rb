RSpec.describe Nova::API::Resource::Bill do
  before(:all) do
    Nova::API.configure do |config|
      config.subdomain = 'foobar'
      config.api_key = 'foo-bar'
    end
  end

  describe 'attributes' do
    subject { described_class }

    it { is_expected.to have_attribute(:id, Dry::Types['coercible.integer'].optional) }
    it { is_expected.to have_attribute(:additional_information, Dry::Types['coercible.string'].optional) }
    it { is_expected.to have_attribute(:apportionments, Dry::Types['strict.array'].of(Nova::API::Resource::Bill::Apportionment).optional) }

    context 'apportionments' do
      subject { described_class::Apportionment }

      it { is_expected.to have_attribute(:apportionment_value_ids, Dry::Types['strict.array'].of(Dry::Types['coercible.integer'].optional)) }
      it { is_expected.to have_attribute(:value, Dry::Types['coercible.float']) }
    end

    it { is_expected.to have_attribute(:company_id, Dry::Types['coercible.integer']) }
    it { is_expected.to have_attribute(:date, Dry::Types['coercible.string'].constrained(format: described_class::DATE_REGEX)) }
    it { is_expected.to have_attribute(:document_type, Dry::Types['coercible.integer']) }
    it { is_expected.to have_attribute(:document_number, Dry::Types['coercible.string']) }
    it { is_expected.to have_attribute(:due_type, Dry::Types['coercible.integer']) }
    it { is_expected.to have_attribute(:financial_account_id, Dry::Types['coercible.integer']) }
    it { is_expected.to have_attribute(:first_due_date, Dry::Types['coercible.string'].constrained(format: described_class::DATE_REGEX)) }
    it { is_expected.to have_attribute(:forecast, Dry::Types['strict.bool']) }
    it { is_expected.to have_attribute(:identifier, Dry::Types['coercible.string'].optional) }
    it { is_expected.to have_attribute(:installments, Dry::Types['strict.array'].of(Nova::API::Resource::Installment).optional) }
    it { is_expected.to have_attribute(:installments_number, Dry::Types['coercible.integer']) }
    it { is_expected.to have_attribute(:third_party_id, Dry::Types['coercible.integer']) }
    it { is_expected.to have_attribute(:total_value, Dry::Types['coercible.float']) }
  end

  describe 'document types' do
    subject { described_class::DOCUMENT_TYPE }

    it 'has the invoice mapped as 0' do
      expect(subject::INVOICE).to eq(0)
    end

    it 'has the receipt mapped as 1' do
      expect(subject::RECEIPT).to eq(1)
    end

    it 'has the coupon tax mapped as 2' do
      expect(subject::COUPON_TAX).to eq(2)
    end

    it 'has the bill mapped as 3' do
      expect(subject::BILL).to eq(3)
    end

    it 'has the billet mapped as 4' do
      expect(subject::BILLET).to eq(4)
    end

    it 'has the cheque mapped as 5' do
      expect(subject::CHEQUE).to eq(5)
    end

    it 'has the initial balance mapped as 6' do
      expect(subject::INITIAL_BALANCE).to eq(6)
    end

    it 'has the transference mapped as 7' do
      expect(subject::TRANSFERENCE).to eq(7)
    end

    it 'has the contract mapped as 8' do
      expect(subject::CONTRACT).to eq(8)
    end

    it 'has the other mapped as 9' do
      expect(subject::OTHER).to eq(9)
    end

    it 'has the statement mapped as 10' do
      expect(subject::STATEMENT).to eq(10)
    end
  end

  describe 'due types' do
    subject { described_class::DUE_TYPE }

    it 'has the monthly mapped as 0' do
      expect(subject::MONTHLY).to eq(0)
    end

    it 'has the biweekly mapped as 1' do
      expect(subject::BIWEEKLY).to eq(1)
    end

    it 'has the ten days tax mapped as 2' do
      expect(subject::TEN_DAYS).to eq(2)
    end

    it 'has the fixed mapped as 3' do
      expect(subject::FIXED).to eq(3)
    end

    it 'has the weekly mapped as 4' do
      expect(subject::WEEKLY).to eq(4)
    end
  end

  describe '.endpoint' do
    it 'returns the bill endpoint' do
      expect(described_class.endpoint).to eq('/api/bills')
    end
  end
end
