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

        before do
          stub_request(:post, "#{described_class.base_url}#{described_class.endpoint}/#{id}/write_off").to_return(status: 400, body: JSON.generate({ errors: errors }))
        end

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

        before do
          stub_request(:post, "#{described_class.base_url}#{described_class.endpoint}/#{id}/write_off").to_return(status: 400, body: JSON.generate({ errors: errors }))
        end

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
end
