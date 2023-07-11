RSpec.describe Nova::API::Resource::WriteOff do
  before(:all) do
    Nova::API.configure do |config|
      config.subdomain = 'foobar'
      config.api_key = 'foo-bar'
    end
  end

  describe 'document types' do
    subject { described_class::DOCUMENT_TYPE }

    it 'has the doc mapped as 0' do
      expect(subject::DOC).to eq(0)
    end

    it 'has the ted mapped as 1' do
      expect(subject::TED).to eq(1)
    end

    it 'has the cheque deposit mapped as 2' do
      expect(subject::CHEQUE_DEPOSIT).to eq(2)
    end

    it 'has the cash deposit mapped as 3' do
      expect(subject::CASH_DEPOSIT).to eq(3)
    end

    it 'has the card mapped as 4' do
      expect(subject::CARD).to eq(4)
    end

    it 'has the billet mapped as 5' do
      expect(subject::BANK_SLIP).to eq(5)
    end

    it 'has the cash mapped as 6' do
      expect(subject::CASH).to eq(6)
    end

    it 'has the cheque mapped as 7' do
      expect(subject::CHEQUE).to eq(7)
    end

    it 'has the receipt mapped as 8' do
      expect(subject::RECEIPT).to eq(8)
    end

    it 'has the bank write off mapped as 9' do
      expect(subject::BANK_WRITE_OFF).to eq(9)
    end

    it 'has the statement mapped as 11' do
      expect(subject::STATEMENT).to eq(11)
    end

    it 'has the withdrawal mapped as 12' do
      expect(subject::WITHDRAWAL).to eq(12)
    end

    it 'has the supply mapped as 13' do
      expect(subject::SUPPLY).to eq(13)
    end

    it 'has the pick up mapped as 14' do
      expect(subject::PICK_UP).to eq(14)
    end

    it 'has the deposit mapped as 15' do
      expect(subject::DEPOSIT).to eq(15)
    end

    it 'has the pix mapped as 19' do
      expect(subject::PIX).to eq(19)
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
