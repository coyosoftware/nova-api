RSpec.describe Nova::API::Resource::Bank do
  before(:all) do
    Nova::API.configure do |config|
      config.subdomain = 'foobar'
      config.api_key = 'foo-bar'
    end
  end

  describe 'attributes' do
    subject { described_class }

    it { is_expected.to have_attribute(:id, Dry::Types['coercible.integer'].optional) }
    it { is_expected.to have_attribute(:company, Nova::API::Resource::Company.optional) }
    it { is_expected.to have_attribute(:deleted, Dry::Types['strict.bool'].optional) }
    it { is_expected.to have_attribute(:image, Dry::Types['coercible.string'].optional) }
    it { is_expected.to have_attribute(:balance, Dry::Types['coercible.decimal'].optional) }

    it { is_expected.to have_attribute(:agency, Dry::Types['coercible.string'].optional) }
    it { is_expected.to have_attribute(:current_account, Dry::Types['coercible.string'].optional) }

    context 'institution' do
      subject { described_class::Institution }

      it { is_expected.to have_attribute(:code, Dry::Types['coercible.string'].optional) }
      it { is_expected.to have_attribute(:name, Dry::Types['coercible.string'].optional) }
    end

    context 'usage' do
      subject { described_class::Usage }

      it { is_expected.to have_attribute(:code, Dry::Types['coercible.integer'].optional) }
      it { is_expected.to have_attribute(:name, Dry::Types['coercible.string'].optional) }
    end
  end

  describe '.endpoint' do
    it 'returns the bank endpoint' do
      expect(described_class.endpoint).to eq('/api/banks')
    end
  end

  describe '.list' do
    let(:company_id) { 99 }
    let(:with_deleted) { true }
    let(:parameters) { { company_id: company_id, with_deleted: with_deleted } }
    let(:data) do
      [
        {
          id: 18, agency: '01413909596380', current_account: '94947502112995',
          company: { id: 6, name: 'Moniz, Velasques e Solimões' },
          deleted: false,
          image: 'https://assets.nova.money/images/bank_logos/sicredi.png',
          balance: 0,
          institution: { code: '748', name: 'Sicredi' },
          usage: { code: 0, name: 'Conta corrente' }
        },
        {
          id: 16, agency: '74373006583146', current_account: '49507222165002',
          company: { id: 6, name: 'Moniz, Velasques e Solimões' },
          deleted: false,
          image: 'https://assets.nova.money/images/bank_logos/banrisul.png',
          balance: 0,
          institution: { code: '041', name: 'Banrisul' },
          usage: { code: 1, name: 'Aplicação' }
        }
      ]
    end
    let(:response) { double(:response, success?: true, parsed_response: data) }

    subject { described_class.list(Nova::API::SearchParams::CurrentAsset.new parameters) }

    it 'issues a get to the bank list endpoint' do
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

        expect(response.records).to all(be_a(Nova::API::Resource::Bank))
        
        expect(response.records[0].id).to eq(data[0][:id])
        expect(response.records[0].agency).to eq(data[0][:agency])
        expect(response.records[0].current_account).to eq(data[0][:current_account])
        expect(response.records[0].company.id).to eq(data[0][:company][:id])
        expect(response.records[0].company.name).to eq(data[0][:company][:name])
        expect(response.records[0].deleted).to eq(data[0][:deleted])
        expect(response.records[0].image).to eq(data[0][:image])
        expect(response.records[0].balance).to eq(data[0][:balance])
        expect(response.records[0].institution.code).to eq(data[0][:institution][:code])
        expect(response.records[0].institution.name).to eq(data[0][:institution][:name])
        expect(response.records[0].usage.code).to eq(data[0][:usage][:code])
        expect(response.records[0].usage.name).to eq(data[0][:usage][:name])

        expect(response.records[1].id).to eq(data[1][:id])
        expect(response.records[1].agency).to eq(data[1][:agency])
        expect(response.records[1].current_account).to eq(data[1][:current_account])
        expect(response.records[1].company.id).to eq(data[1][:company][:id])
        expect(response.records[1].company.name).to eq(data[1][:company][:name])
        expect(response.records[1].deleted).to eq(data[1][:deleted])
        expect(response.records[1].image).to eq(data[1][:image])
        expect(response.records[1].balance).to eq(data[1][:balance])
        expect(response.records[1].institution.code).to eq(data[1][:institution][:code])
        expect(response.records[1].institution.name).to eq(data[1][:institution][:name])
        expect(response.records[1].usage.code).to eq(data[1][:usage][:code])
        expect(response.records[1].usage.name).to eq(data[1][:usage][:name])
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
end
