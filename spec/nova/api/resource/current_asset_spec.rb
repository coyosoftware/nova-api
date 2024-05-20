RSpec.describe Nova::API::Resource::CurrentAsset do
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
    it { is_expected.to have_attribute(:active, Dry::Types['strict.bool'].optional) }
    it { is_expected.to have_attribute(:image, Dry::Types['coercible.string'].optional) }
    it { is_expected.to have_attribute(:balance, Dry::Types['coercible.float'].optional) }
  end

  describe '.endpoint' do
    it 'returns the current asset endpoint' do
      expect(described_class.endpoint).to eq('/api/current_assets')
    end
  end

  describe '.statement' do
    let(:company_id) { 99 }
    let(:current_asset_id) { 88 }
    let(:initial_date) { '2020-01-01' }
    let(:final_date) { '2020-01-31' }
    let(:parameters) { { company_id: company_id, current_asset_id: current_asset_id, initial_date: initial_date, final_date: final_date } }
    let(:data) do
      {
        last_statement: -100,
        write_offs: [
          {
            date: '2021-01-02', value: 100,
            financial_account: { id: 36, name: '2.3 - (-) Despesas anuladas' },
            third_party: { id: 5, trading_name: 'Integrated actuating policy' }
          },
          {
            date: '2021-01-03', value: -100,
            financial_account: { id: 22, name: '3.1.7 - Vale transporte' },
            third_party: { id: 4, trading_name: 'Face to face disintermediate intranet' }
          }
        ]
      }
    end
    let(:response) { double(:response, success?: true, parsed_response: data, code: 200) }

    subject { described_class.statement(Nova::API::SearchParams::CurrentAssetStatement.new parameters) }

    it 'issues a get to the current asset statement endpoint' do
      expect(HTTParty).to receive(:get).with("#{described_class.base_url}#{described_class.endpoint}/statement", query: parameters, headers: authorization_header, format: :json).and_return(response)

      subject
    end

    context 'with a successful response' do
      before do
        stub_request(:get, "#{described_class.base_url}#{described_class.endpoint}/statement").with(query: parameters).
          to_return(status: 200, body: JSON.generate(data))
      end

      it 'returns the response object' do
        expect(subject).to be_a(Nova::API::Response)
      end

      it 'returns no error' do
        response = subject

        expect(response.errors).to be_empty
      end

      it 'returns the record' do
        response = subject

        expect(response.record).to be_a(Nova::API::Resource::Response::CurrentAssetStatement)

        expect(response.record.last_statement).to eq(data[:last_statement])
        expect(response.record.write_offs).to all(be_a(Nova::API::Resource::WriteOff))

        expect(response.record.write_offs[0].date).to eq(data[:write_offs][0][:date])
        expect(response.record.write_offs[0].value).to eq(data[:write_offs][0][:value])
        expect(response.record.write_offs[0].financial_account.id).to eq(data[:write_offs][0][:financial_account][:id])
        expect(response.record.write_offs[0].financial_account.name).to eq(data[:write_offs][0][:financial_account][:name])
        expect(response.record.write_offs[0].third_party.id).to eq(data[:write_offs][0][:third_party][:id])
        expect(response.record.write_offs[0].third_party.trading_name).to eq(data[:write_offs][0][:third_party][:trading_name])

        expect(response.record.write_offs[1].date).to eq(data[:write_offs][1][:date])
        expect(response.record.write_offs[1].value).to eq(data[:write_offs][1][:value])
        expect(response.record.write_offs[1].financial_account.id).to eq(data[:write_offs][1][:financial_account][:id])
        expect(response.record.write_offs[1].financial_account.name).to eq(data[:write_offs][1][:financial_account][:name])
        expect(response.record.write_offs[1].third_party.id).to eq(data[:write_offs][1][:third_party][:id])
        expect(response.record.write_offs[1].third_party.trading_name).to eq(data[:write_offs][1][:third_party][:trading_name])
      end
    end

    context 'with an error response' do
      let(:errors) { ['foo', 'bar'] }

      before do
        stub_request(:get, "#{described_class.base_url}#{described_class.endpoint}/statement").with(query: parameters).
          to_return(status: 400, body: JSON.generate({ errors: errors }))
      end

      it 'returns the response object' do
        expect(subject).to be_a(Nova::API::Response)
      end

      it 'returns the errors' do
        response = subject

        expect(response.record).to be_a(Nova::API::Resource::Response::CurrentAssetStatement)
        expect(response.errors).to match_array(errors)
      end
    end
  end

  describe '#statement' do
    let(:company_id) { 99 }
    let(:current_asset_id) { 88 }
    let(:initial_date) { '2020-01-01' }
    let(:final_date) { '2020-01-31' }
    let(:parameters) { { company: { id: company_id } } }

    context 'when the id is not set' do
      subject { described_class.new(parameters) }

      it 'raises the missing id error' do
        expect { subject.statement(initial_date, final_date) }.to raise_error(Nova::API::MissingIdError, 'This operation requires an ID to be set')
      end
    end

    context 'when the id is set' do
      let(:query_params) { { company_id: company_id, current_asset_id: current_asset_id, final_date: final_date, initial_date: initial_date } }
      let(:data) do
        {
          last_statement: -100,
          write_offs: [
            {
              date: '2021-01-02', value: 100,
              financial_account: { id: 36, name: '2.3 - (-) Despesas anuladas' },
              third_party: { id: 5, trading_name: 'Integrated actuating policy' }
            },
            {
              date: '2021-01-03', value: -100,
              financial_account: { id: 22, name: '3.1.7 - Vale transporte' },
              third_party: { id: 4, trading_name: 'Face to face disintermediate intranet' }
            }
          ]
        }
      end
      let(:response) { double(:response, success?: true, parsed_response: data, code: 200) }

      subject { described_class.new(parameters.merge(id: current_asset_id)) }

      it 'issues a get to the current asset statement endpoint' do
        expect(HTTParty).to receive(:get).with("#{described_class.base_url}#{described_class.endpoint}/statement", query: query_params, headers: authorization_header, format: :json).and_return(response)

        subject.statement(initial_date, final_date)
      end

      context 'with a successful response' do
        before do
          stub_request(:get, "#{described_class.base_url}#{described_class.endpoint}/statement").with(query: query_params).
            to_return(status: 200, body: JSON.generate(data))
        end

        it 'returns the response object' do
          expect(subject.statement(initial_date, final_date)).to be_a(Nova::API::Response)
        end

        it 'returns no error' do
          response = subject.statement(initial_date, final_date)

          expect(response.errors).to be_empty
        end

        it 'returns the record' do
          response = subject.statement(initial_date, final_date)

          expect(response.record).to be_a(Nova::API::Resource::Response::CurrentAssetStatement)

          expect(response.record.last_statement).to eq(data[:last_statement])
          expect(response.record.write_offs).to all(be_a(Nova::API::Resource::WriteOff))

          expect(response.record.write_offs[0].date).to eq(data[:write_offs][0][:date])
          expect(response.record.write_offs[0].value).to eq(data[:write_offs][0][:value])
          expect(response.record.write_offs[0].financial_account.id).to eq(data[:write_offs][0][:financial_account][:id])
          expect(response.record.write_offs[0].financial_account.name).to eq(data[:write_offs][0][:financial_account][:name])
          expect(response.record.write_offs[0].third_party.id).to eq(data[:write_offs][0][:third_party][:id])
          expect(response.record.write_offs[0].third_party.trading_name).to eq(data[:write_offs][0][:third_party][:trading_name])

          expect(response.record.write_offs[1].date).to eq(data[:write_offs][1][:date])
          expect(response.record.write_offs[1].value).to eq(data[:write_offs][1][:value])
          expect(response.record.write_offs[1].financial_account.id).to eq(data[:write_offs][1][:financial_account][:id])
          expect(response.record.write_offs[1].financial_account.name).to eq(data[:write_offs][1][:financial_account][:name])
          expect(response.record.write_offs[1].third_party.id).to eq(data[:write_offs][1][:third_party][:id])
          expect(response.record.write_offs[1].third_party.trading_name).to eq(data[:write_offs][1][:third_party][:trading_name])
        end
      end

      context 'with an error response' do
        let(:errors) { ['foo', 'bar'] }

        before do
          stub_request(:get, "#{described_class.base_url}#{described_class.endpoint}/statement").with(query: query_params).
            to_return(status: 400, body: JSON.generate({ errors: errors }))
        end

        it 'returns the response object' do
        expect(subject.statement(initial_date, final_date)).to be_a(Nova::API::Response)
      end

      it 'returns the errors' do
        response = subject.statement(initial_date, final_date)

        expect(response.record).to be_a(Nova::API::Resource::Response::CurrentAssetStatement)
        expect(response.errors).to match_array(errors)
      end
      end
    end
  end
end
