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
    it 'returns the installments endpoint' do
      expect(described_class.endpoint).to eq('/api/installments')
    end
  end

  describe '.write_off' do
    let(:addition) { BigDecimal('3.98') }
    let(:card_tax_id) { 99 }
    let(:current_asset_id) { 99 }
    let(:date) { '2021-01-15' }
    let(:discount) { BigDecimal('10.32') }
    let(:document_type) { 0 }
    let(:document_number) { 'ABC123' }
    let(:extra_installment) { { due_date: '2021-01-29', value: BigDecimal('5.98') } }
    let(:write_offs) { [{ card_tax_id:, current_asset_id:, document_number:, document_type:, value: BigDecimal('151') }] }
    let(:parameters) { { date:, discount:, addition:, extra_installment:, write_offs: } }
    let(:response) { double(:response, success?: true, code: 201, parsed_response: nil) }

    subject { described_class.write_off(id, parameters) }

    context 'when the id is not set' do
      it 'raises the missing id error' do
        expect { described_class.write_off(nil, parameters) }.to raise_error(Nova::API::MissingIdError, 'This operation requires an ID to be set')
      end
    end

    context 'when the id is set' do
      let(:id) { 99 }

      it 'issues a post to the installment write off endpoint' do
        expect(HTTParty).to receive(:post).with("#{described_class.base_url}#{described_class.endpoint}/#{id}/write_off", body: parameters, headers: authorization_header, format: :json).and_return(response)

        subject
      end

      context 'with a successful response' do
        let(:id) { 99 }

        before { stub_request(:post, "#{described_class.base_url}#{described_class.endpoint}/#{id}/write_off").to_return(status: 201) }

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

        before { stub_request(:post, "#{described_class.base_url}#{described_class.endpoint}/#{id}/write_off").to_return(status: 400, body: JSON.generate(errors:)) }

        it 'returns the response object' do
          expect(subject).to be_a(Nova::API::Response)
        end

        it 'returns the write off installment with its errors' do
          response = subject

          expect(response.record).to be_a(Nova::API::Resource::Installment::WriteOffInstallment)
          expect(response.errors).to match_array(errors)
        end
      end
    end
  end

  describe '.cancel_write_offs' do
    context 'when the id is not set' do
      subject { described_class.cancel_write_offs(nil) }

      it 'raises the missing id error' do
        expect { subject }.to raise_error(Nova::API::MissingIdError, 'This operation requires an ID to be set')
      end
    end

    context 'when the id is set' do
      let(:id) { 99 }
      let(:response) { double(:response, success?: true, parsed_response: nil, code: 200) }

      subject { described_class.cancel_write_offs(id) }

      it 'issues a delete to the installment write offs cancellation endpoint' do
        expect(HTTParty).to receive(:delete).with("#{described_class.base_url}#{described_class.endpoint}/#{id}/cancel_write_offs", headers: authorization_header, format: :json).and_return(response)

        subject
      end

      context 'with a successful response' do
        before { stub_request(:delete, "#{described_class.base_url}#{described_class.endpoint}/#{id}/cancel_write_offs").to_return(status: 200, body: nil) }

        it 'returns the response object' do
          expect(subject).to be_a(Nova::API::Response)
        end

        it 'returns no error' do
          expect(subject.errors).to be_empty
        end

        it 'returns no record' do
          expect(subject.record).to be_nil
        end
      end

      context 'with an error response' do
        let(:errors) { ['foo', 'bar'] }

        before { stub_request(:delete, "#{described_class.base_url}#{described_class.endpoint}/#{id}/cancel_write_offs").to_return(status: 400, body: JSON.generate(errors:)) }

        it 'returns the response object' do
          expect(subject).to be_a(Nova::API::Response)
        end

        it 'returns the errors' do
          expect(subject.errors).to match_array(errors)
        end

        it 'returns no record' do
          expect(subject.record).to be_nil
        end
      end
    end
  end

  describe '#write_off' do
    let(:addition) { BigDecimal('3.98') }
    let(:card_tax_id) { 99 }
    let(:current_asset_id) { 99 }
    let(:date) { '2021-01-15' }
    let(:discount) { BigDecimal('10.32') }
    let(:document_type) { 0 }
    let(:document_number) { 'ABC123' }
    let(:extra_installment) { { due_date: '2021-01-29', value: BigDecimal('5.98') } }
    let(:write_offs) { [{ card_tax_id:, current_asset_id:, document_number:, document_type:, value: BigDecimal('151') }] }
    let(:parameters) { { date:, discount:, addition:, extra_installment:, write_offs: } }
    let(:installment_parameters) { { due_date: '2025-01-01', number: 1, value: BigDecimal('100') } }
    let(:response) { double(:response, success?: true, code: 201, parsed_response: nil) }

    subject { described_class.new(installment_parameters) }

    context 'when the id is not set' do
      it 'raises the missing id error' do
        expect { subject.write_off(parameters) }.to raise_error(Nova::API::MissingIdError, 'This operation requires an ID to be set')
      end
    end

    context 'when the id is set' do
      subject { described_class.new(installment_parameters.merge(id:)) }

      let(:id) { 99 }

      it 'issues a post to the installment write off endpoint' do
        expect(HTTParty).to receive(:post).with("#{described_class.base_url}#{described_class.endpoint}/#{id}/write_off", body: parameters, headers: authorization_header, format: :json).and_return(response)

        subject.write_off(parameters)
      end

      context 'with a successful response' do
        let(:id) { 99 }

        before { stub_request(:post, "#{described_class.base_url}#{described_class.endpoint}/#{id}/write_off").to_return(status: 201) }

        it 'returns the response object' do
          expect(subject.write_off(parameters)).to be_a(Nova::API::Response)
        end

        it 'returns no error' do
          response = subject.write_off(parameters)

          expect(response.errors).to be_empty
        end
      end

      context 'with an error response' do
        let(:errors) { ['foo', 'bar'] }

        before { stub_request(:post, "#{described_class.base_url}#{described_class.endpoint}/#{id}/write_off").to_return(status: 400, body: JSON.generate(errors:)) }

        it 'returns the response object' do
          expect(subject.write_off(parameters)).to be_a(Nova::API::Response)
        end

        it 'returns the write off installment with its errors' do
          response = subject.write_off(parameters)

          expect(response.record).to be_a(Nova::API::Resource::Installment::WriteOffInstallment)
          expect(response.errors).to match_array(errors)
        end
      end
    end
  end

  describe '#cancel_write_offs' do
    context 'when the id is not set' do
      subject { described_class.initialize_empty_model_with_id(described_class, nil, due_date: Date.today.iso8601) }

      it 'raises the missing id error' do
        expect { subject.cancel_write_offs }.to raise_error(Nova::API::MissingIdError, 'This operation requires an ID to be set')
      end
    end

    context 'when the id is set' do
      let(:id) { 99 }
      let(:response) { double(:response, success?: true, parsed_response: { id: id }, code: 200) }

      subject { described_class.initialize_empty_model_with_id(described_class, id, due_date: Date.today.iso8601) }

      it 'issues a delete to the installment write offs cancellation endpoint' do
        expect(HTTParty).to receive(:delete).with("#{described_class.base_url}#{described_class.endpoint}/#{id}/cancel_write_offs", headers: authorization_header, format: :json).and_return(response)

        subject.cancel_write_offs
      end

      context 'with a successful response' do
        before { stub_request(:delete, "#{described_class.base_url}#{described_class.endpoint}/#{id}/cancel_write_offs").to_return(status: 200, body: nil) }

        it 'returns the response object' do
          expect(subject.cancel_write_offs).to be_a(Nova::API::Response)
        end

        it 'returns no error' do
          response = subject.cancel_write_offs

          expect(response.errors).to be_empty
        end
      end

      context 'with an error response' do
        let(:errors) { ['foo', 'bar'] }

        before { stub_request(:delete, "#{described_class.base_url}#{described_class.endpoint}/#{id}/cancel_write_offs").to_return(status: 400, body: JSON.generate(errors:)) }

       it 'returns the response object' do
          expect(subject.cancel_write_offs).to be_a(Nova::API::Response)
        end

        it 'returns the errors' do
          response = subject.cancel_write_offs

          expect(response.errors).to match_array(errors)
        end

        it 'returns no record' do
          response = subject.cancel_write_offs

          expect(response.record).to be_nil
        end
      end
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
    let(:installment_parameters) { { due_date: '2025-01-01', number: 1, value: BigDecimal('100') } }
    let(:parameters) do
      {
        additional_information:, apportionments:, close:, date:, document_type:,
        document_number:, due_date:, financial_accounts: [{ financial_account_id:, value: }],
        gross_value:, value:
      }
    end
    let(:response) { double(:response, success?: true, code: 201, parsed_response: nil) }

    subject { described_class.new(installment_parameters) }

    context 'when the id is not set' do
      it 'raises the missing id error' do
        expect { subject.confirm(parameters) }.to raise_error(Nova::API::MissingIdError, 'This operation requires an ID to be set')
      end
    end

    context 'when the id is set' do
      subject { described_class.new(installment_parameters.merge(id:)) }

      let(:id) { 99 }
      let(:forecast) { double(:forecast, confirm: true) }

      it 'initializes a new forecast' do
        expect(Nova::API::Resource::Forecast).to receive(:new).with(parameters.merge(id:)).and_return(forecast)

        subject.confirm(parameters)
      end

      it 'confirms the forecast' do
        expect_any_instance_of(Nova::API::Resource::Forecast).to receive(:confirm).and_return(response)

        subject.confirm(parameters)
      end
    end
  end

  shared_examples 'a forecast operation' do |operation, path_suffix|
    let(:installment_parameters) { { due_date: '2025-01-01', number: 1, value: BigDecimal('100') } }

    context 'when the id is not set' do
      subject { described_class.new(installment_parameters) }

      it 'raises the missing id error' do
        expect { subject.public_send(operation) }.to raise_error(Nova::API::MissingIdError, 'This operation requires an ID to be set')
      end
    end

    context 'when the id is set' do
      subject { described_class.new(installment_parameters.merge(id:)) }

      let(:id) { 99 }
      let(:url) { "#{described_class.base_url}#{Nova::API::Resource::Forecast.endpoint}/#{id}#{path_suffix}" }

      before { stub_request(:delete, url).to_return(status: 200, body: nil) }

      it 'issues a delete to the forecast endpoint' do
        subject.public_send(operation)

        expect(a_request(:delete, url)).to have_been_made.once
      end

      it 'returns the response object' do
        expect(subject.public_send(operation)).to be_a(Nova::API::Response)
      end
    end
  end

  describe '#cancel_forecast' do
    it_behaves_like 'a forecast operation', :cancel_forecast, '/cancel'
  end

  describe '#destroy_forecast' do
    it_behaves_like 'a forecast operation', :destroy_forecast, ''
  end
end
