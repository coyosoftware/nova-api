RSpec.describe Nova::API::Resource::Card do
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

    it { is_expected.to have_attribute(:description, Dry::Types['coercible.string'].optional) }
    it { is_expected.to have_attribute(:institution, Dry::Types['coercible.string'].optional) }
  end

  describe '.endpoint' do
    it 'returns the card endpoint' do
      expect(described_class.endpoint).to eq('/api/cards')
    end
  end

  describe '.list' do
    let(:company_id) { 99 }
    let(:with_deleted) { true }
    let(:parameters) { { company_id: company_id, with_deleted: with_deleted } }
    let(:data) do
      [
        {
          id: 18, company: { id: 6, name: 'Moniz, Velasques e Solimões' }, deleted: false, description: 'Antunes Comércio',
          image: 'https://assets.nova.money/images/card_logos/mercadopago.png', balance: 0, institution: 'Mercado Pago'
        },
        {
          id: 22, company: { id: 6, name: 'Moniz, Velasques e Solimões' }, deleted: false, description: 'Castanho-Custódio',
          image: 'https://assets.nova.money/images/card_logos/izettle.png', balance: 0, institution: 'iZettle'
        }
      ]
    end
    let(:response) { double(:response, success?: true, parsed_response: data) }

    subject { described_class.list(Nova::API::SearchParams::CurrentAsset.new parameters) }

    it 'issues a get to the card list endpoint' do
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

        expect(response.records).to all(be_a(Nova::API::Resource::Card))
        
        expect(response.records[0].id).to eq(data[0][:id])
        expect(response.records[0].company.id).to eq(data[0][:company][:id])
        expect(response.records[0].company.name).to eq(data[0][:company][:name])
        expect(response.records[0].deleted).to eq(data[0][:deleted])
        expect(response.records[0].image).to eq(data[0][:image])
        expect(response.records[0].balance).to eq(data[0][:balance])
        expect(response.records[0].description).to eq(data[0][:description])
        expect(response.records[0].institution).to eq(data[0][:institution])

        expect(response.records[1].id).to eq(data[1][:id])
        expect(response.records[1].company.id).to eq(data[1][:company][:id])
        expect(response.records[1].company.name).to eq(data[1][:company][:name])
        expect(response.records[1].deleted).to eq(data[1][:deleted])
        expect(response.records[1].image).to eq(data[1][:image])
        expect(response.records[1].balance).to eq(data[1][:balance])
        expect(response.records[1].description).to eq(data[1][:description])
        expect(response.records[1].institution).to eq(data[1][:institution])
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
