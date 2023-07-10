RSpec.describe Nova::API::Resource::Payable do
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

    it { is_expected.to have_attribute(:attachments, Dry::Types['strict.array'].of(Dry::Types['coercible.string']).optional) }
    it { is_expected.to have_attribute(:company_id, Dry::Types['coercible.integer']) }
    it { is_expected.to have_attribute(:date, Dry::Types['coercible.string'].constrained(format: described_class::DATE_REGEX)) }
    it { is_expected.to have_attribute(:document_type, Dry::Types['coercible.integer']) }
    it { is_expected.to have_attribute(:document_number, Dry::Types['coercible.string']) }
    it { is_expected.to have_attribute(:due_type, Dry::Types['coercible.integer']) }
    it { is_expected.to have_attribute(:financial_accounts, Dry::Types['strict.array'].of(Nova::API::Resource::Bill::FinancialAccount).optional) }

    context 'financial accounts' do
      subject { described_class::FinancialAccount }

      it { is_expected.to have_attribute(:financial_account_id, Dry::Types['coercible.integer']) }
      it { is_expected.to have_attribute(:value, Dry::Types['coercible.float']) }
    end

    it { is_expected.to have_attribute(:first_due_date, Dry::Types['coercible.string'].constrained(format: described_class::DATE_REGEX)) }
    it { is_expected.to have_attribute(:forecast, Dry::Types['strict.bool']) }
    it { is_expected.to have_attribute(:identifier, Dry::Types['coercible.string'].optional) }
    it { is_expected.to have_attribute(:installments, Dry::Types['strict.array'].of(Nova::API::Resource::Installment).optional) }
    it { is_expected.to have_attribute(:installments_number, Dry::Types['coercible.integer']) }
    it { is_expected.to have_attribute(:third_party_id, Dry::Types['coercible.integer']) }
    it { is_expected.to have_attribute(:total_value, Dry::Types['coercible.float']) }
  end

  describe '.endpoint' do
    it 'returns the payable endpoint' do
      expect(described_class.endpoint).to eq('/api/payables')
    end
  end

  describe '.list' do
    let(:parameters) { { identifier: 'foobar' } }
    let(:data) do
      [
        {
          additional_information: nil, apportionments: [{ apportionment_value_ids: [1,2,3], value: 10.45 }], company_id: 20, date: '2021-03-12',
          document_type: Nova::API::Resource::Bill::DOCUMENT_TYPE::INVOICE, document_number: '11198',
          due_type: Nova::API::Resource::Bill::DUE_TYPE::MONTHLY, financial_accounts: [{ financial_account_id: 22, value: 10.45 }],
          first_due_date: '2021-03-12', forecast: false, id: 16, identifier: 'foobar',
          installments: [{ due_date: '2021-03-12', id: 11, number: 1, value: 10.45 }], installments_number: 1, third_party_id: 38,
          total_value: 10.45
        },
        {
          additional_information: nil, apportionments: [{ apportionment_value_ids: [1,2], value: 102.44 }], company_id: 20, date: '2021-03-12',
          document_type: Nova::API::Resource::Bill::DOCUMENT_TYPE::INVOICE, document_number: '11199',
          due_type: Nova::API::Resource::Bill::DUE_TYPE::MONTHLY, financial_accounts: [{ financial_account_id: 22, value: 102.44 }],
          first_due_date: '2021-03-12', forecast: false, id: 17, identifier: 'foobar',
          installments: [{ due_date: '2021-03-12', id: 12, number: 1, value: 102.44 }], installments_number: 1, third_party_id: 38,
          total_value: 102.44
        }
      ]
    end
    let(:response) { double(:response, success?: true, parsed_response: data, code: 200) }

    subject { described_class.list(Nova::API::SearchParams::Bill.new parameters) }

    it 'issues a get to the payable list endpoint' do
      expect(described_class).to receive(:get).with(described_class.endpoint, query: parameters, headers: authorization_header).and_return(response)

      subject
    end

    context 'with a successful response' do
      before do
        stub_request(:get, "#{described_class.base_url}#{described_class.endpoint}").with(query: parameters).
          to_return(status: 200, body: JSON.generate(data))
      end

      it 'returns the response object' do
        expect(subject).to be_a(Nova::API::ListResponse)
      end

      it 'returns no error' do
        response = subject

        expect(response.errors).to be_empty
      end

      it 'returns the records' do
        response = subject

        expect(response.records).to all(be_a(Nova::API::Resource::Payable))

        expect(response.records[0].additional_information).to eq(data[0][:additional_information])

        expect(response.records[0].apportionments).to all(be_a(Nova::API::Resource::Payable::Apportionment))
        expect(response.records[0].apportionments[0].apportionment_value_ids).to match_array(data[0][:apportionments][0][:apportionment_value_ids])
        expect(response.records[0].apportionments[0].value).to eq(data[0][:apportionments][0][:value])

        expect(response.records[0].company_id).to eq(data[0][:company_id])
        expect(response.records[0].date).to eq(data[0][:date])
        expect(response.records[0].document_type).to eq(data[0][:document_type])
        expect(response.records[0].document_number).to eq(data[0][:document_number])
        expect(response.records[0].due_type).to eq(data[0][:due_type])

        expect(response.records[0].financial_accounts).to all(be_a(Nova::API::Resource::Payable::FinancialAccount))
        expect(response.records[0].financial_accounts[0].financial_account_id).to eq(data[0][:financial_accounts][0][:financial_account_id])
        expect(response.records[0].financial_accounts[0].value).to eq(data[0][:financial_accounts][0][:value])

        expect(response.records[0].first_due_date).to eq(data[0][:first_due_date])
        expect(response.records[0].forecast).to eq(data[0][:forecast])
        expect(response.records[0].id).to eq(data[0][:id])
        expect(response.records[0].identifier).to eq(data[0][:identifier])

        expect(response.records[0].installments).to all(be_a(Nova::API::Resource::Installment))
        expect(response.records[0].installments[0].due_date).to eq(data[0][:installments][0][:due_date])
        expect(response.records[0].installments[0].id).to eq(data[0][:installments][0][:id])
        expect(response.records[0].installments[0].number).to eq(data[0][:installments][0][:number])
        expect(response.records[0].installments[0].value).to eq(data[0][:installments][0][:value])

        expect(response.records[0].installments_number).to eq(data[0][:installments_number])
        expect(response.records[0].third_party_id).to eq(data[0][:third_party_id])
        expect(response.records[0].total_value).to eq(data[0][:total_value])

        expect(response.records[1].additional_information).to eq(data[1][:additional_information])

        expect(response.records[1].apportionments).to all(be_a(Nova::API::Resource::Payable::Apportionment))
        expect(response.records[1].apportionments[0].apportionment_value_ids).to match_array(data[1][:apportionments][0][:apportionment_value_ids])
        expect(response.records[1].apportionments[0].value).to eq(data[1][:apportionments][0][:value])

        expect(response.records[1].company_id).to eq(data[1][:company_id])
        expect(response.records[1].date).to eq(data[1][:date])
        expect(response.records[1].document_type).to eq(data[1][:document_type])
        expect(response.records[1].document_number).to eq(data[1][:document_number])
        expect(response.records[1].due_type).to eq(data[1][:due_type])

        expect(response.records[1].financial_accounts).to all(be_a(Nova::API::Resource::Payable::FinancialAccount))
        expect(response.records[1].financial_accounts[0].financial_account_id).to eq(data[1][:financial_accounts][0][:financial_account_id])
        expect(response.records[1].financial_accounts[0].value).to eq(data[1][:financial_accounts][0][:value])

        expect(response.records[1].first_due_date).to eq(data[1][:first_due_date])
        expect(response.records[1].forecast).to eq(data[1][:forecast])
        expect(response.records[1].id).to eq(data[1][:id])
        expect(response.records[1].identifier).to eq(data[1][:identifier])

        expect(response.records[1].installments).to all(be_a(Nova::API::Resource::Installment))
        expect(response.records[1].installments[0].due_date).to eq(data[1][:installments][0][:due_date])
        expect(response.records[1].installments[0].id).to eq(data[1][:installments][0][:id])
        expect(response.records[1].installments[0].number).to eq(data[1][:installments][0][:number])
        expect(response.records[1].installments[0].value).to eq(data[1][:installments][0][:value])

        expect(response.records[1].installments_number).to eq(data[1][:installments_number])
        expect(response.records[1].third_party_id).to eq(data[1][:third_party_id])
        expect(response.records[1].total_value).to eq(data[1][:total_value])
      end
    end

    context 'with an error response' do
      let(:errors) { ['foo', 'bar'] }

      before do
        stub_request(:get, "#{described_class.base_url}#{described_class.endpoint}").with(query: parameters).
          to_return(status: 400, body: JSON.generate({ errors: errors }))
      end

      it 'returns the response object' do
        expect(subject).to be_a(Nova::API::ListResponse)
      end

      it 'returns the errors' do
        response = subject

        expect(response.records).to be_nil
        expect(response.errors).to match_array(errors)
      end
    end
  end

  describe '.create' do
    let(:additional_information) { 'foobar' }
    let(:company_id) { 99 }
    let(:date) { '2021-01-15' }
    let(:document_type) { 0 }
    let(:document_number) { 'ABC123' }
    let(:due_type) { 0 }
    let(:financial_account_id) { 98 }
    let(:first_due_date) { '2021-01-16' }
    let(:third_party_id) { 88 }
    let(:total_value) { BigDecimal('151') }
    let(:apportionments) do
      [ { apportionment_value_ids: [1, 2, 3], value: BigDecimal('100.33') }, { apportionment_value_ids: [4, 5, nil], value: BigDecimal('50.67') } ]
    end
    let(:installments) do
      [
        { due_date: '2021-01-16', number: 1, value: BigDecimal('51') },
        { due_date: '2021-02-16', number: 2, value: BigDecimal('50') },
        { due_date: '2021-03-16', number: 3, value: BigDecimal('50') }
      ]
    end
    let(:parameters) do
      {
        additional_information: additional_information, apportionments: apportionments, company_id: company_id, date: date, document_type: document_type,
        document_number: document_number, due_type: due_type, financial_accounts: [{ financial_account_id: financial_account_id, value: total_value }],
        first_due_date: first_due_date, forecast: false, installments: installments, installments_number: installments.size,
        third_party_id: third_party_id, total_value: total_value
      }
    end
    let(:response) { double(:response, success?: true, parsed_response: { id: 99 }, code: 201) }

    subject { described_class.create(parameters) }

    it 'issues a post to the payable create endpoint' do
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

  describe '.update' do
    let(:additional_information) { 'foobar' }
    let(:company_id) { 99 }
    let(:date) { '2021-01-15' }
    let(:document_type) { 0 }
    let(:document_number) { 'ABC123' }
    let(:due_type) { 0 }
    let(:financial_account_id) { 98 }
    let(:first_due_date) { '2021-01-16' }
    let(:third_party_id) { 88 }
    let(:total_value) { BigDecimal('151') }
    let(:apportionments) do
      [ { apportionment_value_ids: [1, 2, 3], value: BigDecimal('100.33') }, { apportionment_value_ids: [4, 5, nil], value: BigDecimal('50.67') } ]
    end
    let(:installments) do
      [
        { due_date: '2021-01-16', number: 1, value: BigDecimal('51') },
        { due_date: '2021-02-16', number: 2, value: BigDecimal('50') },
        { due_date: '2021-03-16', number: 3, value: BigDecimal('50') }
      ]
    end
    let(:parameters) do
      {
        additional_information: additional_information, apportionments: apportionments, company_id: company_id, date: date, document_type: document_type,
        document_number: document_number, due_type: due_type, financial_accounts: [{ financial_account_id: financial_account_id, value: total_value }],
        first_due_date: first_due_date, forecast: false, installments: installments, installments_number: installments.size,
        third_party_id: third_party_id, total_value: total_value
      }
    end

    context 'when the id is not set' do
      it 'raises the missing id error' do
        expect { described_class.update(nil, parameters) }.to raise_error(Nova::API::MissingIdError, 'This operation requires an ID to be set')
      end
    end

    context 'when the id is set' do
      let(:id) { 99 }
      let(:response) { double(:response, success?: true, parsed_response: { id: 99 }, code: 200) }

      subject { described_class.update(id, parameters) }

      it 'issues a patch to the payable update endpoint' do
        expect(described_class).to receive(:patch).with("#{described_class.endpoint}/#{id}", body: parameters, headers: authorization_header).and_return(response)

        subject
      end

      context 'with a successful response' do
        before do
          stub_request(:patch, "#{described_class.base_url}#{described_class.endpoint}/#{id}").
            to_return(status: 200, body: nil)
        end

        it 'returns the response object' do
          expect(subject).to be_a(Nova::API::Response)
        end

        it 'returns no error' do
          response = subject

          expect(response.errors).to be_empty
        end

        it 'returns the updated payable' do
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
          stub_request(:patch, "#{described_class.base_url}#{described_class.endpoint}/#{id}").
            to_return(status: 400, body: JSON.generate({ errors: errors }))
        end

        it 'returns the response object' do
          expect(subject).to be_a(Nova::API::Response)
        end

        it 'returns the third party with its errors' do
          response = subject

          expect(response.record).to be_a(described_class)
          expect(response.errors).to match_array(errors)
        end
      end
    end
  end

  describe '.destroy' do
    context 'when the id is not set' do
      subject { described_class.destroy(nil) }

      it 'raises the missing id error' do
        expect { subject }.to raise_error(Nova::API::MissingIdError, 'This operation requires an ID to be set')
      end
    end

    context 'when the id is set' do
      let(:id) { 99 }
      let(:response) { double(:response, success?: true, parsed_response: nil, code: 200) }

      subject { described_class.destroy(id) }

      it 'issues a delete to the payable delete endpoint' do
        expect(described_class).to receive(:delete).with("#{described_class.endpoint}/#{id}", headers: authorization_header).and_return(response)

        subject
      end

      context 'with a successful response' do
        before do
          stub_request(:delete, "#{described_class.base_url}#{described_class.endpoint}/#{id}").
            to_return(status: 200, body: nil)
        end

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

        before do
          stub_request(:delete, "#{described_class.base_url}#{described_class.endpoint}/#{id}").
            to_return(status: 400, body: JSON.generate({ errors: errors }))
        end

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

  describe '#endpoint' do
    let(:id) { 99 }
    let(:company_id) { 99 }
    let(:date) { '2021-01-15' }
    let(:document_type) { 0 }
    let(:due_type) { 0 }
    let(:financial_account_id) { 98 }
    let(:first_due_date) { '2021-01-16' }
    let(:third_party_id) { 88 }
    let(:total_value) { BigDecimal('151') }
    let(:installments) do
      [
        { due_date: '2021-01-16', number: 1, value: BigDecimal('51') },
        { due_date: '2021-02-16', number: 2, value: BigDecimal('50') },
        { due_date: '2021-03-16', number: 3, value: BigDecimal('50') }
      ]
    end
    let(:parameters) do
      {
        id: id, company_id: company_id, date: date, document_type: document_type, due_type: due_type,
        financial_accounts: [{ financial_account_id: financial_account_id, value: total_value }], first_due_date: first_due_date,
        forecast: false, installments: installments, installments_number: installments.size, third_party_id: third_party_id, total_value: total_value
      }
    end

    subject { described_class.new(parameters) }

    it 'returns the apportionment endpoint' do
      expect(subject.endpoint).to eq("/api/payables/#{id}")
    end
  end

  describe '#save' do
    let(:additional_information) { 'foobar' }
    let(:company_id) { 99 }
    let(:date) { '2021-01-15' }
    let(:document_type) { 0 }
    let(:document_number) { 'ABC123' }
    let(:due_type) { 0 }
    let(:financial_account_id) { 98 }
    let(:first_due_date) { '2021-01-16' }
    let(:third_party_id) { 88 }
    let(:total_value) { BigDecimal('151') }
    let(:apportionments) do
      [ { apportionment_value_ids: [1, 2, 3], value: BigDecimal('100.33') }, { apportionment_value_ids: [4, 5, nil], value: BigDecimal('50.67') } ]
    end
    let(:installments) do
      [
        { due_date: '2021-01-16', number: 1, value: BigDecimal('51') },
        { due_date: '2021-02-16', number: 2, value: BigDecimal('50') },
        { due_date: '2021-03-16', number: 3, value: BigDecimal('50') }
      ]
    end
    let(:parameters) do
      {
        additional_information: additional_information, apportionments: apportionments, company_id: company_id, date: date, document_type: document_type,
        document_number: document_number, due_type: due_type, financial_accounts: [{ financial_account_id: financial_account_id, value: total_value }],
        first_due_date: first_due_date, forecast: false, installments: installments, installments_number: installments.size,
        third_party_id: third_party_id, total_value: total_value
      }
    end

    context 'when the id is not set' do
      let(:response) { double(:response, success?: true, parsed_response: { id: 99 }, code: 201) }

      subject { described_class.new(parameters) }

      it 'issues a post to the payable create endpoint' do
        expect(described_class).to receive(:post).with(described_class.endpoint, body: parameters, headers: authorization_header).and_return(response)

        subject.save
      end

      context 'with a successful response' do
        let(:id) { 99 }

        before do
          stub_request(:post, "#{described_class.base_url}#{described_class.endpoint}").
            to_return(status: 201, body: JSON.generate({ id: id }))
        end

        it 'returns the response object' do
          expect(subject.save).to be_a(Nova::API::Response)
        end

        it 'returns no error' do
          response = subject.save

          expect(response.errors).to be_empty
        end

        it 'returns the created payable' do
          response = subject.save

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
          expect(subject.save).to be_a(Nova::API::Response)
        end

        it 'returns the payable with its errors' do
          response = subject.save

          expect(response.record).to be_a(described_class)
          expect(response.errors).to match_array(errors)
        end
      end
    end

    context 'when the id is set' do
      let(:id) { 99 }
      let(:response) { double(:response, success?: true, parsed_response: nil, code: 200) }

      subject { described_class.new(parameters.merge(id: id)) }

      it 'issues a patch to the payable update endpoint' do
        expect(described_class).to receive(:patch).with("#{described_class.endpoint}/#{id}", body: parameters, headers: authorization_header).and_return(response)

        subject.save
      end

      context 'with a successful response' do
        before do
          stub_request(:patch, "#{described_class.base_url}#{described_class.endpoint}/#{id}").
            to_return(status: 200, body: nil)
        end

        it 'returns the response object' do
          expect(subject.save).to be_a(Nova::API::Response)
        end

        it 'returns no error' do
          response = subject.save

          expect(response.errors).to be_empty
        end

        it 'returns the updated payable' do
          response = subject.save

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
          stub_request(:patch, "#{described_class.base_url}#{described_class.endpoint}/#{id}").
            to_return(status: 400, body: JSON.generate({ errors: errors }))
        end

        it 'returns the response object' do
          expect(subject.save).to be_a(Nova::API::Response)
        end

        it 'returns the payable with its errors' do
          response = subject.save

          expect(response.record).to be_a(described_class)
          expect(response.errors).to match_array(errors)
        end
      end
    end
  end

  describe '#update' do
    let(:additional_information) { 'foobar' }
    let(:company_id) { 99 }
    let(:date) { '2021-01-15' }
    let(:document_type) { 0 }
    let(:document_number) { 'ABC123' }
    let(:due_type) { 0 }
    let(:financial_account_id) { 98 }
    let(:first_due_date) { '2021-01-16' }
    let(:third_party_id) { 88 }
    let(:total_value) { BigDecimal('151') }
    let(:apportionments) do
      [ { apportionment_value_ids: [1, 2, 3], value: BigDecimal('100.33') }, { apportionment_value_ids: [4, 5, nil], value: BigDecimal('50.67') } ]
    end
    let(:installments) do
      [
        { due_date: '2021-01-16', number: 1, value: BigDecimal('51') },
        { due_date: '2021-02-16', number: 2, value: BigDecimal('50') },
        { due_date: '2021-03-16', number: 3, value: BigDecimal('50') }
      ]
    end
    let(:parameters) do
      {
        additional_information: additional_information, apportionments: apportionments, company_id: company_id, date: date, document_type: document_type,
        document_number: document_number, due_type: due_type, financial_accounts: [{ financial_account_id: financial_account_id, value: total_value }],
        first_due_date: first_due_date, forecast: false, installments: installments, installments_number: installments.size,
        third_party_id: third_party_id, total_value: total_value
      }
    end

    context 'when the id is not set' do
      subject { described_class.new(parameters) }

      it 'raises the missing id error' do
        expect { subject.update }.to raise_error(Nova::API::MissingIdError, 'This operation requires an ID to be set')
      end
    end

    context 'when the id is set' do
      let(:id) { 99 }
      let(:response) { double(:response, success?: true, parsed_response: { id: 99 }, code: 200) }

      subject { described_class.new(parameters.merge(id: id)) }

      it 'issues a patch to the payable update endpoint' do
        expect(described_class).to receive(:patch).with("#{described_class.endpoint}/#{id}", body: parameters, headers: authorization_header).and_return(response)

        subject.update
      end

      context 'with a successful response' do
        before do
          stub_request(:patch, "#{described_class.base_url}#{described_class.endpoint}/#{id}").
            to_return(status: 200, body: nil)
        end

        it 'returns the response object' do
          expect(subject.update).to be_a(Nova::API::Response)
        end

        it 'returns no error' do
          response = subject.update

          expect(response.errors).to be_empty
        end

        it 'returns the updated payable' do
          response = subject.update

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
          stub_request(:patch, "#{described_class.base_url}#{described_class.endpoint}/#{id}").
            to_return(status: 400, body: JSON.generate({ errors: errors }))
        end

        it 'returns the response object' do
          expect(subject.update).to be_a(Nova::API::Response)
        end

        it 'returns the payable with its errors' do
          response = subject.update

          expect(response.record).to be_a(described_class)
          expect(response.errors).to match_array(errors)
        end
      end
    end
  end

  describe '#destroy' do
    let(:company_id) { 99 }
    let(:date) { '2021-01-15' }
    let(:document_type) { 0 }
    let(:due_type) { 0 }
    let(:financial_account_id) { 98 }
    let(:first_due_date) { '2021-01-16' }
    let(:third_party_id) { 88 }
    let(:total_value) { BigDecimal('151') }
    let(:installments) do
      [
        { due_date: '2021-01-16', number: 1, value: BigDecimal('51') },
        { due_date: '2021-02-16', number: 2, value: BigDecimal('50') },
        { due_date: '2021-03-16', number: 3, value: BigDecimal('50') }
      ]
    end
    let(:parameters) do
      {
        company_id: company_id, date: date, document_type: document_type, due_type: due_type,
        financial_accounts: [{ financial_account_id: financial_account_id, value: total_value }], first_due_date: first_due_date,
        forecast: false, installments: installments, installments_number: installments.size, third_party_id: third_party_id, total_value: total_value

      }
    end

    context 'when the id is not set' do
      subject { described_class.new(parameters) }

      it 'raises the missing id error' do
        expect { subject.destroy }.to raise_error(Nova::API::MissingIdError, 'This operation requires an ID to be set')
      end
    end

    context 'when the id is set' do
      let(:id) { 99 }
      let(:response) { double(:response, success?: true, parsed_response: nil, code: 200) }

      subject { described_class.new(parameters.merge(id: id)) }

      it 'issues a delete to the payable delete endpoint' do
        expect(described_class).to receive(:delete).with("#{described_class.endpoint}/#{id}", headers: authorization_header).and_return(response)

        subject.destroy
      end

      context 'with a successful response' do
        before do
          stub_request(:delete, "#{described_class.base_url}#{described_class.endpoint}/#{id}").
            to_return(status: 200, body: nil)
        end

        it 'returns the response object' do
          expect(subject.destroy).to be_a(Nova::API::Response)
        end

        it 'returns no error' do
          response = subject.destroy

          expect(response.errors).to be_empty
        end

        it 'returns no record' do
          response = subject.destroy

          expect(response.record).to be_nil
        end
      end

      context 'with an error response' do
        let(:errors) { ['foo', 'bar'] }

        before do
          stub_request(:delete, "#{described_class.base_url}#{described_class.endpoint}/#{id}").
            to_return(status: 400, body: JSON.generate({ errors: errors }))
        end

        it 'returns the response object' do
          expect(subject.destroy).to be_a(Nova::API::Response)
        end

        it 'returns the errors' do
          response = subject.destroy

          expect(response.errors).to match_array(errors)
        end

        it 'returns no record' do
          response = subject.destroy

          expect(response.record).to be_nil
        end
      end
    end
  end
end
