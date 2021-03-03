RSpec.describe Nova::API::Resource::FinancialAccount do
  before(:all) do
    Nova::API.configure do |config|
      config.subdomain = 'foobar'
      config.api_key = 'foo-bar'
    end
  end

  describe 'attributes' do
    subject { described_class }

    it { is_expected.to have_attribute(:id, Dry::Types['coercible.integer'].optional) }
    it { is_expected.to have_attribute(:name, Dry::Types['coercible.string']) }
    it { is_expected.to have_attribute(:reason, Dry::Types['coercible.integer'].optional) }
    it { is_expected.to have_attribute(:financial_account_id, Dry::Types['coercible.integer'].optional) }
    it { is_expected.to have_attribute(:financial_account, Dry::Types['coercible.string'].optional) }
    it { is_expected.to have_attribute(:income, Dry::Types['strict.bool'].optional) }
    it { is_expected.to have_attribute(:outcome, Dry::Types['strict.bool'].optional) }
    it { is_expected.to have_attribute(:children, Dry::Types['strict.array'].of(Nova::API::Resource::FinancialAccount).optional) }
  end

  describe '.endpoint' do
    it 'returns the financial account endpoint' do
      expect(described_class.endpoint).to eq('/api/financial_accounts')
    end
  end

  describe '.list' do
    let(:data) do
      [
        {
          'id': 1, 'name': '0 - Ativo', 'reason': 0, 'financial_account_id': nil, 'financial_account': nil, 'income': true, 'outcome': false,
          'children': [ { 'id': 27, 'name': '0.0 - Caixas', 'reason': 0, 'financial_account_id': 1, 'financial_account': '0 - Ativo', 'income': true, 'outcome': false } ]
        },
        {
          'id': 8, 'name': '3 - Custo', 'reason': 3, 'financial_account_id': nil, 'financial_account': nil, 'income': false, 'outcome': true,
          'children': [
            {
              'id': 9, 'name': '3.0 - Gasto com pessoal', 'reason': 3, 'financial_account_id': 8, 'financial_account': '3 - Custo', 'income': false, 'outcome': true,
              'children': [ { 'id': 11, 'name': '3.0.0 - Salário', 'reason': 3, 'financial_account_id': 9, 'financial_account': '3.0 - Gasto com pessoal', 'income': false, 'outcome': true } ]
            }
          ]
        }
      ]
    end
    let(:response) do
      double(:response, success?: true, parsed_response: data)
    end

    subject { described_class.list }

    it 'issues a get to the financial account list endpoint' do
      expect(described_class).to receive(:get).with(described_class.endpoint, headers: authorization_header).and_return(response)

      subject
    end

    context 'with a successful response' do
      before do
        stub_request(:get, "#{described_class.base_url}#{described_class.endpoint}").
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

        expect(response.records).to all(be_a(Nova::API::Resource::FinancialAccount))

        expect(response.records[0].id).to eq(data[0][:id])
        expect(response.records[0].name).to eq(data[0][:name])
        expect(response.records[0].reason).to eq(data[0][:reason])
        expect(response.records[0].financial_account_id).to eq(data[0][:financial_account_id])
        expect(response.records[0].financial_account).to eq(data[0][:financial_account])
        expect(response.records[0].income).to eq(data[0][:income])
        expect(response.records[0].outcome).to eq(data[0][:outcome])
        expect(response.records[0].children).to all(be_a(Nova::API::Resource::FinancialAccount))

        expect(response.records[0].children[0].id).to eq(data[0][:children][0][:id])
        expect(response.records[0].children[0].name).to eq(data[0][:children][0][:name])
        expect(response.records[0].children[0].reason).to eq(data[0][:children][0][:reason])
        expect(response.records[0].children[0].financial_account_id).to eq(data[0][:children][0][:financial_account_id])
        expect(response.records[0].children[0].financial_account).to eq(data[0][:children][0][:financial_account])
        expect(response.records[0].children[0].income).to eq(data[0][:children][0][:income])
        expect(response.records[0].children[0].outcome).to eq(data[0][:children][0][:outcome])

        expect(response.records[1].id).to eq(data[1][:id])
        expect(response.records[1].name).to eq(data[1][:name])
        expect(response.records[1].reason).to eq(data[1][:reason])
        expect(response.records[1].financial_account_id).to eq(data[1][:financial_account_id])
        expect(response.records[1].financial_account).to eq(data[1][:financial_account])
        expect(response.records[1].income).to eq(data[1][:income])
        expect(response.records[1].outcome).to eq(data[1][:outcome])
        expect(response.records[1].children).to all(be_a(Nova::API::Resource::FinancialAccount))

        expect(response.records[1].children[0].id).to eq(data[1][:children][0][:id])
        expect(response.records[1].children[0].name).to eq(data[1][:children][0][:name])
        expect(response.records[1].children[0].reason).to eq(data[1][:children][0][:reason])
        expect(response.records[1].children[0].financial_account_id).to eq(data[1][:children][0][:financial_account_id])
        expect(response.records[1].children[0].financial_account).to eq(data[1][:children][0][:financial_account])
        expect(response.records[1].children[0].income).to eq(data[1][:children][0][:income])
        expect(response.records[1].children[0].outcome).to eq(data[1][:children][0][:outcome])

        expect(response.records[1].children[0].children).to all(be_a(Nova::API::Resource::FinancialAccount))
        expect(response.records[1].children[0].children[0].id).to eq(data[1][:children][0][:children][0][:id])
        expect(response.records[1].children[0].children[0].name).to eq(data[1][:children][0][:children][0][:name])
        expect(response.records[1].children[0].children[0].reason).to eq(data[1][:children][0][:children][0][:reason])
        expect(response.records[1].children[0].children[0].financial_account_id).to eq(data[1][:children][0][:children][0][:financial_account_id])
        expect(response.records[1].children[0].children[0].financial_account).to eq(data[1][:children][0][:children][0][:financial_account])
        expect(response.records[1].children[0].children[0].income).to eq(data[1][:children][0][:children][0][:income])
        expect(response.records[1].children[0].children[0].outcome).to eq(data[1][:children][0][:children][0][:outcome])
      end
    end

    context 'with an error response' do
      let(:errors) { ['foo', 'bar'] }

      before do
        stub_request(:get, "#{described_class.base_url}#{described_class.endpoint}").
          to_return(status: 400, body: JSON.generate({ errors: errors }))
      end

      it 'returns the response object' do
        expect(subject).to be_a(Nova::API::ListResponse)
      end

      it 'returns the financial account with its errors' do
        response = subject

        expect(response.records).to be_nil
        expect(response.errors).to match_array(errors)
      end
    end
  end

  describe '.income_accounts' do
    let(:data) do
      [
        {
          'id': 3, 'name': '2 - Receita', 'reason': 2, 'financial_account_id': nil, 'financial_account': nil, 'income': true, 'outcome': false,
          'children': [ { 'id': 4, 'name': '2.0 - Receita privado', 'reason': 2, 'financial_account_id': 3, 'financial_account': '2 - Receita', 'income': true, 'outcome': false } ]
        },
        {
          'id': 8, 'name': '3 - Custo', 'reason': 3, 'financial_account_id': nil, 'financial_account': nil, 'income': false, 'outcome': true,
          'children': [
            {
              'id': 9, 'name': '3.0 - Gasto com pessoal', 'reason': 3, 'financial_account_id': 8, 'financial_account': '3 - Custo', 'income': false, 'outcome': true,
              'children': [ { 'id': 11, 'name': '3.0.0 - Salário', 'reason': 3, 'financial_account_id': 9, 'financial_account': '3.0 - Gasto com pessoal', 'income': false, 'outcome': true } ]
            }
          ]
        }
      ]
    end
    let(:response) do
      double(:response, success?: true, parsed_response: data)
    end

    subject { described_class.income_accounts }

    it 'issues a get to the income financial account list endpoint' do
      expect(described_class).to receive(:get).with("#{described_class.endpoint}/income_accounts", headers: authorization_header).and_return(response)

      subject
    end

    context 'with a successful response' do
      before do
        stub_request(:get, "#{described_class.base_url}#{described_class.endpoint}/income_accounts").
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

        expect(response.records).to all(be_a(Nova::API::Resource::FinancialAccount))

        expect(response.records[0].id).to eq(data[0][:id])
        expect(response.records[0].name).to eq(data[0][:name])
        expect(response.records[0].reason).to eq(data[0][:reason])
        expect(response.records[0].financial_account_id).to eq(data[0][:financial_account_id])
        expect(response.records[0].financial_account).to eq(data[0][:financial_account])
        expect(response.records[0].income).to eq(data[0][:income])
        expect(response.records[0].outcome).to eq(data[0][:outcome])
        expect(response.records[0].children).to all(be_a(Nova::API::Resource::FinancialAccount))

        expect(response.records[0].children[0].id).to eq(data[0][:children][0][:id])
        expect(response.records[0].children[0].name).to eq(data[0][:children][0][:name])
        expect(response.records[0].children[0].reason).to eq(data[0][:children][0][:reason])
        expect(response.records[0].children[0].financial_account_id).to eq(data[0][:children][0][:financial_account_id])
        expect(response.records[0].children[0].financial_account).to eq(data[0][:children][0][:financial_account])
        expect(response.records[0].children[0].income).to eq(data[0][:children][0][:income])
        expect(response.records[0].children[0].outcome).to eq(data[0][:children][0][:outcome])

        expect(response.records[1].id).to eq(data[1][:id])
        expect(response.records[1].name).to eq(data[1][:name])
        expect(response.records[1].reason).to eq(data[1][:reason])
        expect(response.records[1].financial_account_id).to eq(data[1][:financial_account_id])
        expect(response.records[1].financial_account).to eq(data[1][:financial_account])
        expect(response.records[1].income).to eq(data[1][:income])
        expect(response.records[1].outcome).to eq(data[1][:outcome])
        expect(response.records[1].children).to all(be_a(Nova::API::Resource::FinancialAccount))

        expect(response.records[1].children[0].id).to eq(data[1][:children][0][:id])
        expect(response.records[1].children[0].name).to eq(data[1][:children][0][:name])
        expect(response.records[1].children[0].reason).to eq(data[1][:children][0][:reason])
        expect(response.records[1].children[0].financial_account_id).to eq(data[1][:children][0][:financial_account_id])
        expect(response.records[1].children[0].financial_account).to eq(data[1][:children][0][:financial_account])
        expect(response.records[1].children[0].income).to eq(data[1][:children][0][:income])
        expect(response.records[1].children[0].outcome).to eq(data[1][:children][0][:outcome])

        expect(response.records[1].children[0].children).to all(be_a(Nova::API::Resource::FinancialAccount))
        expect(response.records[1].children[0].children[0].id).to eq(data[1][:children][0][:children][0][:id])
        expect(response.records[1].children[0].children[0].name).to eq(data[1][:children][0][:children][0][:name])
        expect(response.records[1].children[0].children[0].reason).to eq(data[1][:children][0][:children][0][:reason])
        expect(response.records[1].children[0].children[0].financial_account_id).to eq(data[1][:children][0][:children][0][:financial_account_id])
        expect(response.records[1].children[0].children[0].financial_account).to eq(data[1][:children][0][:children][0][:financial_account])
        expect(response.records[1].children[0].children[0].income).to eq(data[1][:children][0][:children][0][:income])
        expect(response.records[1].children[0].children[0].outcome).to eq(data[1][:children][0][:children][0][:outcome])
      end
    end

    context 'with an error response' do
      let(:errors) { ['foo', 'bar'] }

      before do
        stub_request(:get, "#{described_class.base_url}#{described_class.endpoint}/income_accounts").
          to_return(status: 400, body: JSON.generate({ errors: errors }))
      end

      it 'returns the response object' do
        expect(subject).to be_a(Nova::API::ListResponse)
      end

      it 'returns the financial account with its errors' do
        response = subject

        expect(response.records).to be_nil
        expect(response.errors).to match_array(errors)
      end
    end
  end

  describe '.payable_accounts' do
    let(:data) do
      [
        {
          'id': 8, 'name': '3 - Custo', 'reason': 3, 'financial_account_id': nil, 'financial_account': nil, 'income': false, 'outcome': true,
          'children': [
            {
              'id': 9, 'name': '3.0 - Gasto com pessoal', 'reason': 3, 'financial_account_id': 8, 'financial_account': '3 - Custo', 'income': false, 'outcome': true,
              'children': [ { 'id': 11, 'name': '3.0.0 - Salário', 'reason': 3, 'financial_account_id': 9, 'financial_account': '3.0 - Gasto com pessoal', 'income': false, 'outcome': true } ]
            }
          ]
        },
        {
          'id': 23, 'name': '4 - Despesa', 'reason': 4, 'financial_account_id': nil, 'financial_account': nil, 'income': false, 'outcome': true,
          'children': [
            {
              'id': 24, 'name': '4.0 - Despesas financeiras', 'reason': 4, 'financial_account_id': 23, 'financial_account': '4 - Despesa', 'income': false, 'outcome': true,
              'children': [ { 'id': 25, 'name': '4.0.0 - Taxas', 'reason': 4, 'financial_account_id': 24, 'financial_account': '4.0 - Despesas financeiras', 'income': false, 'outcome': true } ]
            }
          ]
        }
      ]
    end
    let(:response) do
      double(:response, success?: true, parsed_response: data)
    end

    subject { described_class.payable_accounts }

    it 'issues a get to the payable financial account list endpoint' do
      expect(described_class).to receive(:get).with("#{described_class.endpoint}/payable_accounts", headers: authorization_header).and_return(response)

      subject
    end

    context 'with a successful response' do
      before do
        stub_request(:get, "#{described_class.base_url}#{described_class.endpoint}/payable_accounts").
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

        expect(response.records).to all(be_a(Nova::API::Resource::FinancialAccount))

        expect(response.records[0].id).to eq(data[0][:id])
        expect(response.records[0].name).to eq(data[0][:name])
        expect(response.records[0].reason).to eq(data[0][:reason])
        expect(response.records[0].financial_account_id).to eq(data[0][:financial_account_id])
        expect(response.records[0].financial_account).to eq(data[0][:financial_account])
        expect(response.records[0].income).to eq(data[0][:income])
        expect(response.records[0].outcome).to eq(data[0][:outcome])
        expect(response.records[0].children).to all(be_a(Nova::API::Resource::FinancialAccount))

        expect(response.records[0].children[0].id).to eq(data[0][:children][0][:id])
        expect(response.records[0].children[0].name).to eq(data[0][:children][0][:name])
        expect(response.records[0].children[0].reason).to eq(data[0][:children][0][:reason])
        expect(response.records[0].children[0].financial_account_id).to eq(data[0][:children][0][:financial_account_id])
        expect(response.records[0].children[0].financial_account).to eq(data[0][:children][0][:financial_account])
        expect(response.records[0].children[0].income).to eq(data[0][:children][0][:income])
        expect(response.records[0].children[0].outcome).to eq(data[0][:children][0][:outcome])

        expect(response.records[0].children[0].children).to all(be_a(Nova::API::Resource::FinancialAccount))
        expect(response.records[0].children[0].children[0].id).to eq(data[0][:children][0][:children][0][:id])
        expect(response.records[0].children[0].children[0].name).to eq(data[0][:children][0][:children][0][:name])
        expect(response.records[0].children[0].children[0].reason).to eq(data[0][:children][0][:children][0][:reason])
        expect(response.records[0].children[0].children[0].financial_account_id).to eq(data[0][:children][0][:children][0][:financial_account_id])
        expect(response.records[0].children[0].children[0].financial_account).to eq(data[0][:children][0][:children][0][:financial_account])
        expect(response.records[0].children[0].children[0].income).to eq(data[0][:children][0][:children][0][:income])
        expect(response.records[0].children[0].children[0].outcome).to eq(data[0][:children][0][:children][0][:outcome])

        expect(response.records[1].id).to eq(data[1][:id])
        expect(response.records[1].name).to eq(data[1][:name])
        expect(response.records[1].reason).to eq(data[1][:reason])
        expect(response.records[1].financial_account_id).to eq(data[1][:financial_account_id])
        expect(response.records[1].financial_account).to eq(data[1][:financial_account])
        expect(response.records[1].income).to eq(data[1][:income])
        expect(response.records[1].outcome).to eq(data[1][:outcome])
        expect(response.records[1].children).to all(be_a(Nova::API::Resource::FinancialAccount))

        expect(response.records[1].children[0].id).to eq(data[1][:children][0][:id])
        expect(response.records[1].children[0].name).to eq(data[1][:children][0][:name])
        expect(response.records[1].children[0].reason).to eq(data[1][:children][0][:reason])
        expect(response.records[1].children[0].financial_account_id).to eq(data[1][:children][0][:financial_account_id])
        expect(response.records[1].children[0].financial_account).to eq(data[1][:children][0][:financial_account])
        expect(response.records[1].children[0].income).to eq(data[1][:children][0][:income])
        expect(response.records[1].children[0].outcome).to eq(data[1][:children][0][:outcome])

        expect(response.records[1].children[0].children).to all(be_a(Nova::API::Resource::FinancialAccount))
        expect(response.records[1].children[0].children[0].id).to eq(data[1][:children][0][:children][0][:id])
        expect(response.records[1].children[0].children[0].name).to eq(data[1][:children][0][:children][0][:name])
        expect(response.records[1].children[0].children[0].reason).to eq(data[1][:children][0][:children][0][:reason])
        expect(response.records[1].children[0].children[0].financial_account_id).to eq(data[1][:children][0][:children][0][:financial_account_id])
        expect(response.records[1].children[0].children[0].financial_account).to eq(data[1][:children][0][:children][0][:financial_account])
        expect(response.records[1].children[0].children[0].income).to eq(data[1][:children][0][:children][0][:income])
        expect(response.records[1].children[0].children[0].outcome).to eq(data[1][:children][0][:children][0][:outcome])
      end
    end

    context 'with an error response' do
      let(:errors) { ['foo', 'bar'] }

      before do
        stub_request(:get, "#{described_class.base_url}#{described_class.endpoint}/payable_accounts").
          to_return(status: 400, body: JSON.generate({ errors: errors }))
      end

      it 'returns the response object' do
        expect(subject).to be_a(Nova::API::ListResponse)
      end

      it 'returns the financial account with its errors' do
        response = subject

        expect(response.records).to be_nil
        expect(response.errors).to match_array(errors)
      end
    end
  end

  describe '.receivable_accounts' do
    let(:data) do
      [
        {
          'id': 3, 'name': '2 - Receita', 'reason': 2, 'financial_account_id': nil, 'financial_account': nil, 'income': true, 'outcome': false,
          'children': [
            {
              'id': 4, 'name': '2.0 - Receita privado', 'reason': 2, 'financial_account_id': 3, 'financial_account': '2 - Receita', 'income': true, 'outcome': false
            }
          ]
        }
      ]
    end
    let(:response) do
      double(:response, success?: true, parsed_response: data)
    end

    subject { described_class.receivable_accounts }

    it 'issues a get to the receivable financial account list endpoint' do
      expect(described_class).to receive(:get).with("#{described_class.endpoint}/receivable_accounts", headers: authorization_header).and_return(response)

      subject
    end

    context 'with a successful response' do
      before do
        stub_request(:get, "#{described_class.base_url}#{described_class.endpoint}/receivable_accounts").
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

        expect(response.records).to all(be_a(Nova::API::Resource::FinancialAccount))

        expect(response.records[0].id).to eq(data[0][:id])
        expect(response.records[0].name).to eq(data[0][:name])
        expect(response.records[0].reason).to eq(data[0][:reason])
        expect(response.records[0].financial_account_id).to eq(data[0][:financial_account_id])
        expect(response.records[0].financial_account).to eq(data[0][:financial_account])
        expect(response.records[0].income).to eq(data[0][:income])
        expect(response.records[0].outcome).to eq(data[0][:outcome])
        expect(response.records[0].children).to all(be_a(Nova::API::Resource::FinancialAccount))

        expect(response.records[0].children[0].id).to eq(data[0][:children][0][:id])
        expect(response.records[0].children[0].name).to eq(data[0][:children][0][:name])
        expect(response.records[0].children[0].reason).to eq(data[0][:children][0][:reason])
        expect(response.records[0].children[0].financial_account_id).to eq(data[0][:children][0][:financial_account_id])
        expect(response.records[0].children[0].financial_account).to eq(data[0][:children][0][:financial_account])
        expect(response.records[0].children[0].income).to eq(data[0][:children][0][:income])
        expect(response.records[0].children[0].outcome).to eq(data[0][:children][0][:outcome])
      end
    end

    context 'with an error response' do
      let(:errors) { ['foo', 'bar'] }

      before do
        stub_request(:get, "#{described_class.base_url}#{described_class.endpoint}/receivable_accounts").
          to_return(status: 400, body: JSON.generate({ errors: errors }))
      end

      it 'returns the response object' do
        expect(subject).to be_a(Nova::API::ListResponse)
      end

      it 'returns the financial account with its errors' do
        response = subject

        expect(response.records).to be_nil
        expect(response.errors).to match_array(errors)
      end
    end
  end

  describe '.create' do
    let(:financial_account_id) { 10 }
    let(:name) { 'foobar' }
    let(:parameters) { { name: name, financial_account_id: financial_account_id } }
    let(:response) { double(:response, success?: true, parsed_response: { id: 99 }) }

    subject { described_class.create(parameters) }

    it 'issues a post to the financial account create endpoint' do
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

      it 'returns the created financial account' do
        response = subject

        expect(response.record).to be_a(described_class)
        expect(response.record.name).to eq(name)
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

      it 'returns the financial account with its errors' do
        response = subject

        expect(response.record).to be_a(described_class)
        expect(response.errors).to match_array(errors)
      end
    end
  end

  describe '.update' do
    let(:financial_account_id) { 10 }
    let(:name) { 'foobar' }
    let(:parameters) { { financial_account_id: financial_account_id, name: name } }

    context 'when the id is not set' do
      it 'raises the missing id error' do
        expect { described_class.update(nil, parameters) }.to raise_error(Nova::API::MissingIdError, 'This operation requires an ID to be set')
      end
    end

    context 'when the id is set' do
      let(:id) { 99 }
      let(:response) { double(:response, success?: true, parsed_response: { id: 99 }) }

      subject { described_class.update(id, parameters) }

      it 'issues a patch to the financial account update endpoint' do
        expect(described_class).to receive(:patch).with("#{described_class.endpoint}/#{id}", body: { financial_account_id: financial_account_id, name: name }, headers: authorization_header).and_return(response)

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

        it 'returns the created financial account' do
          response = subject

          expect(response.record).to be_a(described_class)
          expect(response.record.name).to eq(name)
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

        it 'returns the financial account with its errors' do
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
      let(:response) { double(:response, success?: true, parsed_response: nil) }

      subject { described_class.destroy(id) }

      it 'issues a delete to the financial account delete endpoint' do
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
    let(:financial_account_id) { 10 }
    let(:name) { 'foobar' }
    let(:parameters) { { financial_account_id: financial_account_id, name: name, id: id } }

    subject { described_class.new(parameters) }

    it 'returns the financial account endpoint' do
      expect(subject.endpoint).to eq("/api/financial_accounts/#{id}")
    end
  end

  describe '#save' do
    context 'when the id is not set' do
      let(:financial_account_id) { 10 }
      let(:name) { 'foobar' }
      let(:parameters) { { financial_account_id: financial_account_id, name: name } }
      let(:response) { double(:response, success?: true, parsed_response: { id: 99 }) }

      subject { described_class.new(parameters) }

      it 'issues a post to the financial account create endpoint' do
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

        it 'returns the created financial account' do
          response = subject.save

          expect(response.record).to be_a(described_class)
          expect(response.record.name).to eq(name)
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

        it 'returns the financial account with its errors' do
          response = subject.save

          expect(response.record).to be_a(described_class)
          expect(response.errors).to match_array(errors)
        end
      end
    end

    context 'when the id is set' do
      let(:id) { 99 }
      let(:name) { 'foobar' }
      let(:financial_account_id) { 10 }
      let(:parameters) { { id: id, financial_account_id: financial_account_id, name: name } }
      let(:response) { double(:response, success?: true, parsed_response: nil) }

      subject { described_class.new(parameters) }

      it 'issues a patch to the financial account update endpoint' do
        expect(described_class).to receive(:patch).with("#{described_class.endpoint}/#{id}", body: { financial_account_id: financial_account_id, name: name }, headers: authorization_header).and_return(response)

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

        it 'returns the created financial account' do
          response = subject.save

          expect(response.record).to be_a(described_class)
          expect(response.record.name).to eq(name)
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

        it 'returns the financial account with its errors' do
          response = subject.save

          expect(response.record).to be_a(described_class)
          expect(response.errors).to match_array(errors)
        end
      end
    end
  end

  describe '#update' do
    context 'when the id is not set' do
      let(:name) { 'foobar' }
      let(:financial_account_id) { 10 }
      let(:parameters) { { financial_account_id: financial_account_id, name: name } }

      subject { described_class.new(parameters) }

      it 'raises the missing id error' do
        expect { subject.update }.to raise_error(Nova::API::MissingIdError, 'This operation requires an ID to be set')
      end
    end

    context 'when the id is set' do
      let(:id) { 99 }
      let(:name) { 'foobar' }
      let(:financial_account_id) { 10 }
      let(:parameters) { { id: id, financial_account_id: financial_account_id, name: name } }
      let(:response) { double(:response, success?: true, parsed_response: { id: 99 }) }

      subject { described_class.new(parameters) }

      it 'issues a patch to the financial account update endpoint' do
        expect(described_class).to receive(:patch).with("#{described_class.endpoint}/#{id}", body: { financial_account_id: financial_account_id, name: name }, headers: authorization_header).and_return(response)

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

        it 'returns the created financial account' do
          response = subject.update

          expect(response.record).to be_a(described_class)
          expect(response.record.name).to eq(name)
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

        it 'returns the financial account with its errors' do
          response = subject.update

          expect(response.record).to be_a(described_class)
          expect(response.errors).to match_array(errors)
        end
      end
    end
  end

  describe '#destroy' do
    context 'when the id is not set' do
      let(:name) { 'foobar' }
      let(:parameters) { { name: name } }
      
      subject { described_class.new(parameters) }

      it 'raises the missing id error' do
        expect { subject.destroy }.to raise_error(Nova::API::MissingIdError, 'This operation requires an ID to be set')
      end
    end

    context 'when the id is set' do
      let(:id) { 99 }
      let(:name) { 'foobar' }
      let(:parameters) { { id: id, name: name } }
      let(:response) { double(:response, success?: true, parsed_response: nil) }

      subject { described_class.new(parameters) }

      it 'issues a delete to the financial account delete endpoint' do
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
