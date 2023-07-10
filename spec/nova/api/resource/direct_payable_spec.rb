RSpec.describe Nova::API::Resource::DirectPayable do
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
    it 'returns the save direct payables endpoint' do
      expect(described_class.endpoint).to eq('/api/payables/save_direct')
    end
  end

  describe '.create' do
    let(:addition) { BigDecimal('12.2') }
    let(:additional_information) { 'foobar' }
    let(:attachments) { ['foobar'] }
    let(:company_id) { 99 }
    let(:current_asset_id) { 99 }
    let(:date) { '2021-01-15' }
    let(:document_type) { 0 }
    let(:document_number) { 'ABC123' }
    let(:financial_account_id) { 98 }
    let(:first_due_date) { '2021-01-16' }
    let(:third_party_id) { 88 }
    let(:total_value) { BigDecimal('151') }
    let(:apportionments) do
      [ { apportionment_value_ids: [1, 2, 3], value: BigDecimal('100.33') }, { apportionment_value_ids: [4, 5, nil], value: BigDecimal('50.67') } ]
    end
    let(:installments) do
      [
        { current_asset_id: current_asset_id, document_number: '123ABC', document_type: document_type, due_date: '2021-01-16', value: BigDecimal('151') }
      ]
    end
    let(:parameters) do
      {
        addition: addition, additional_information: additional_information, apportionments: apportionments, attachments: attachments,
        company_id: company_id, date: date, document_type: document_type, document_number: document_number,
        financial_accounts: [{ financial_account_id: financial_account_id, value: total_value }], first_due_date: first_due_date, 
        installments: installments, identifier: '#123', third_party_id: third_party_id, total_value: total_value
      }
    end
    let(:response) { double(:response, success?: true, parsed_response: { id: 99 }, code: 201) }

    subject { described_class.create(parameters) }

    it 'issues a post to the payable save direct endpoint' do
      expect(described_class).to receive(:post).with(described_class.endpoint, body: parameters, headers: authorization_header).and_return(response)

      subject
    end

    context 'with a successful response' do
      let(:id) { 99 }

      before do
        stub_request(:post, "#{described_class.base_url}#{described_class.endpoint}").
          to_return(status: 201, body: JSON.generate({ id: id }))
      end

      it 'returns the response object' do
        expect(subject).to be_a(Nova::API::Response)
      end

      it 'returns no error' do
        response = subject

        expect(response.errors).to be_empty
      end

      it 'returns the created payable' do
        response = subject

        expect(response.record).to be_a(described_class)

        parameters.keys.each do |field|
          data = response.record.send(field.to_sym)

          if data.is_a? Array
            data.each_with_index do |data, index|
              if data.respond_to? :attributes
                expect(data.attributes).to eq(parameters[field][index])
              else
                expect(data).to eq(parameters[field][index])
              end
            end
          else
            expect(data).to eq(parameters[field])
          end
        end

        expect(response.record.id).to eq(id)
      end
    end

    context 'with an error response' do
      let(:errors) { ['foo', 'bar'] }

      before do
        stub_request(:post, "#{described_class.base_url}#{described_class.endpoint}").
          to_return(status: 400, body: JSON.generate({ errors: errors }))
      end

      it 'returns the response object' do
        expect(subject).to be_a(Nova::API::Response)
      end

      it 'returns the payable with its errors' do
        response = subject

        expect(response.record).to be_a(described_class)
        expect(response.errors).to match_array(errors)
      end
    end
  end
end
