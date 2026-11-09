RSpec.describe Nova::API::Resource::Forecast do
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
      subject { Nova::API::Resource::Bill::Apportionment }

      it { is_expected.to have_attribute(:apportionment_value_ids, Dry::Types['strict.array'].of(Dry::Types['coercible.integer'].optional)) }
      it { is_expected.to have_attribute(:value, Dry::Types['coercible.float']) }
    end

    it { is_expected.to have_attribute(:close, Dry::Types['strict.bool']) }
    it { is_expected.to have_attribute(:date, Dry::Types['coercible.string'].constrained(format: described_class::DATE_REGEX)) }
    it { is_expected.to have_attribute(:document_type, Dry::Types['coercible.integer']) }
    it { is_expected.to have_attribute(:document_number, Dry::Types['coercible.string']) }
    it { is_expected.to have_attribute(:due_date, Dry::Types['coercible.string'].constrained(format: described_class::DATE_REGEX)) }
    it { is_expected.to have_attribute(:financial_accounts, Dry::Types['strict.array'].of(Nova::API::Resource::Bill::FinancialAccount).optional) }

    context 'financial accounts' do
      subject { Nova::API::Resource::Bill::FinancialAccount }

      it { is_expected.to have_attribute(:financial_account_id, Dry::Types['coercible.integer']) }
      it { is_expected.to have_attribute(:value, Dry::Types['coercible.float']) }
    end

    it { is_expected.to have_attribute(:gross_value, Dry::Types['coercible.float'].optional) }
    it { is_expected.to have_attribute(:value, Dry::Types['coercible.float']) }
  end

  describe '.endpoint' do
    it 'returns the forecasts endpoint' do
      expect(described_class.endpoint).to eq('/api/forecasts')
    end
  end

  describe '.confirm' do
    let(:additional_information) { 'foobar' }
    let(:close) { false }
    let(:date) { '2021-01-15' }
    let(:document_type) { 0 }
    let(:document_number) { 'ABC123' }
    let(:due_date) { '2021-01-17' }
    let(:financial_account_id) { 98 }
    let(:first_due_date) { '2021-01-16' }
    let(:gross_value) { BigDecimal('161') }
    let(:third_party_id) { 88 }
    let(:value) { BigDecimal('151') }
    let(:apportionments) do
      [{ apportionment_value_ids: [1, 2, 3], value: BigDecimal('100.33') }, { apportionment_value_ids: [4, 5, nil], value: BigDecimal('50.67') }]
    end
    let(:parameters) do
      {
        additional_information:, apportionments:, close:, date:, document_type:,
        document_number:, due_date:, financial_accounts: [{ financial_account_id:, value: }],
        gross_value:, value:
      }
    end
    let(:response) { double(:response, success?: true, code: 201, parsed_response: nil) }

    subject { described_class.confirm(id, parameters) }

    context 'when the id is not set' do
      it 'raises the missing id error' do
        expect { described_class.confirm(nil, parameters) }.to raise_error(Nova::API::MissingIdError, 'This operation requires an ID to be set')
      end
    end

    context 'when the id is set' do
      let(:id) { 99 }

      it 'issues a post to the forecast confirm endpoint' do
        expect(HTTParty).to receive(:post).with("#{described_class.base_url}#{described_class.endpoint}/#{id}/confirm", body: parameters, headers: authorization_header, format: :json).and_return(response)

        subject
      end

      context 'with a successful response' do
        let(:id) { 99 }

        before { stub_request(:post, "#{described_class.base_url}#{described_class.endpoint}/#{id}/confirm").to_return(status: 201) }

        it 'returns the response object' do
          expect(subject).to be_a(Nova::API::Response)
        end

        it 'returns no error' do
          response = subject

          expect(response.errors).to be_empty
        end
      end

      context 'with an error response' do
        let(:errors) { ['foo', 'bar'] }

        before { stub_request(:post, "#{described_class.base_url}#{described_class.endpoint}/#{id}/confirm").to_return(status: 400, body: JSON.generate(errors:)) }

        it 'returns the response object' do
          expect(subject).to be_a(Nova::API::Response)
        end

        it 'returns the forecast with its errors' do
          response = subject

          expect(response.record).to be_a(Nova::API::Resource::Forecast)
          expect(response.errors).to match_array(errors)
        end
      end
    end
  end

  describe '#endpoint' do
    let(:id) { 99 }
    let(:additional_information) { 'foobar' }
    let(:close) { false }
    let(:date) { '2021-01-15' }
    let(:document_type) { 0 }
    let(:document_number) { 'ABC123' }
    let(:due_date) { '2021-01-17' }
    let(:financial_account_id) { 98 }
    let(:first_due_date) { '2021-01-16' }
    let(:gross_value) { BigDecimal('161') }
    let(:third_party_id) { 88 }
    let(:value) { BigDecimal('151') }
    let(:apportionments) do
      [{ apportionment_value_ids: [1, 2, 3], value: BigDecimal('100.33') }, { apportionment_value_ids: [4, 5, nil], value: BigDecimal('50.67') }]
    end
    let(:parameters) do
      {
        id:, additional_information:, apportionments:, close:, date:, document_type:,
        document_number:, due_date:, financial_accounts: [{ financial_account_id:, value: }],
        gross_value:, value:
      }
    end

    subject { described_class.new(parameters) }

    it 'returns the apportionment endpoint' do
      expect(subject.endpoint).to eq("/api/forecasts/#{id}")
    end
  end

  describe '#confirm' do
    let(:additional_information) { 'foobar' }
    let(:close) { false }
    let(:date) { '2021-01-15' }
    let(:document_type) { 0 }
    let(:document_number) { 'ABC123' }
    let(:due_date) { '2021-01-17' }
    let(:financial_account_id) { 98 }
    let(:first_due_date) { '2021-01-16' }
    let(:gross_value) { BigDecimal('161') }
    let(:third_party_id) { 88 }
    let(:value) { BigDecimal('151') }
    let(:apportionments) do
      [{ apportionment_value_ids: [1, 2, 3], value: BigDecimal('100.33') }, { apportionment_value_ids: [4, 5, nil], value: BigDecimal('50.67') }]
    end
    let(:parameters) do
      {
        additional_information: additional_information, apportionments: apportionments, close: close, date: date, document_type: document_type,
        document_number: document_number, due_date: due_date, financial_accounts: [{ financial_account_id: financial_account_id, value: value }],
        gross_value: gross_value, value: value
      }
    end
    let(:response) { double(:response, success?: true, code: 201, parsed_response: nil) }

    subject { described_class.new(parameters) }

    context 'when the id is not set' do
      it 'raises the missing id error' do
        expect { subject.confirm }.to raise_error(Nova::API::MissingIdError, 'This operation requires an ID to be set')
      end
    end

    context 'when the id is set' do
      subject { described_class.new(parameters.merge(id:)) }

      let(:id) { 99 }

      it 'issues a post to the forecast confirm endpoint' do
        expect(HTTParty).to receive(:post).with("#{described_class.base_url}#{Nova::API::Resource::Forecast.endpoint}/#{id}/confirm", body: parameters, headers: authorization_header, format: :json).and_return(response)

        subject.confirm
      end

      context 'with a successful response' do
        let(:id) { 99 }

        before { stub_request(:post, "#{described_class.base_url}#{Nova::API::Resource::Forecast.endpoint}/#{id}/confirm").to_return(status: 201) }

        it 'returns the response object' do
          expect(subject.confirm).to be_a(Nova::API::Response)
        end

        it 'returns no error' do
          response = subject.confirm

          expect(response.errors).to be_empty
        end
      end

      context 'with an error response' do
        let(:errors) { ['foo', 'bar'] }

        before { stub_request(:post, "#{described_class.base_url}#{described_class.endpoint}/#{id}/confirm").to_return(status: 400, body: JSON.generate(errors:)) }

        it 'returns the response object' do
          expect(subject.confirm).to be_a(Nova::API::Response)
        end

        it 'returns the forecase with its errors' do
          response = subject.confirm

          expect(response.record).to be_a(Nova::API::Resource::Forecast)
          expect(response.errors).to match_array(errors)
        end
      end
    end
  end
end
