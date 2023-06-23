RSpec.describe Nova::API::Resource::Permission do
  before(:all) do
    Nova::API.configure do |config|
      config.subdomain = 'foobar'
      config.api_key = 'foo-bar'
    end
  end

  describe 'attributes' do
    subject { described_class }

    it { is_expected.to have_attribute(:action, Dry::Types['coercible.string']) }
    it { is_expected.to have_attribute(:can, Dry::Types['strict.bool']) }
    it { is_expected.to have_attribute(:subject, Dry::Types['coercible.string']) }
  end

  describe '.endpoint' do
    it 'returns the permissions endpoint' do
      expect(described_class.endpoint).to eq('/api/users/permissions')
    end
  end

  describe '.list' do
    let(:parameters) { { q: 'foobar' } }
    let(:data) do
      [
        { action: 'index', can: true, subject: 'Foobar' },
        { action: 'create', can: true, subject: 'Foobar' }
      ]
    end
    let(:response) { double(:response, success?: true, parsed_response: data, code: 200) }

    subject { described_class.list }

    it 'issues a get to the permissions list endpoint' do
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

        expect(response.records).to all(be_a(Nova::API::Resource::Permission))

        expect(response.records[0].action).to eq(data[0][:action])
        expect(response.records[0].can).to eq(data[0][:can])
        expect(response.records[0].subject).to eq(data[0][:subject])

        expect(response.records[1].action).to eq(data[1][:action])
        expect(response.records[1].can).to eq(data[1][:can])
        expect(response.records[1].subject).to eq(data[1][:subject])
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
