RSpec.describe Nova::API::Resource::Company do
  before(:all) do
    Nova::API.configure do |config|
      config.subdomain = 'foobar'
      config.api_key = 'foo-bar'
    end
  end

  describe 'attributes' do
    subject { described_class }

    it { is_expected.to have_attribute(:id, Dry::Types['coercible.integer'].optional) }
    it { is_expected.to have_attribute(:name, Dry::Types['coercible.string'].optional) }
    it { is_expected.to have_attribute(:trading_name, Dry::Types['coercible.string'].optional) }
  end

  describe '.endpoint' do
    it 'returns the company endpoint' do
      expect(described_class.endpoint).to eq('/api/companies')
    end
  end

  describe '.list' do
    let(:parameters) { { q: 'foobar' } }
    let(:data) do
      [
        { id: 1, name: 'da Penha Comércio', trading_name: nil },
        { id: 2, name: 'Conceição S.A.', trading_name: nil }
      ]
    end
    let(:response) { double(:response, success?: true, parsed_response: data) }

    subject { described_class.list }

    it 'issues a get to the company list endpoint' do
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

        expect(response.records).to all(be_a(Nova::API::Resource::Company))

        expect(response.records[0].id).to eq(data[0][:id])
        expect(response.records[0].name).to eq(data[0][:name])
        expect(response.records[0].trading_name).to eq(data[0][:trading_name])

        expect(response.records[1].id).to eq(data[1][:id])
        expect(response.records[1].name).to eq(data[1][:name])
        expect(response.records[1].trading_name).to eq(data[1][:trading_name])
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

      it 'returns the errors' do
        response = subject

        expect(response.records).to be_nil
        expect(response.errors).to match_array(errors)
      end
    end
  end
end
