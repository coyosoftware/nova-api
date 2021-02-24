RSpec.describe Nova::API::Response do
  describe '.build' do
    context 'when the response is a success' do
      let(:model) { Nova::API::Resource::Apportionment.new(name: 'foobar') }
      let(:response) { double(:response, success?: true, parsed_response: { 'id' => 99 }) }

      it 'extracts the data from the httparty response object' do
        data = described_class.build(response, model)

        expect(data.success).to be_truthy
        expect(data.record).to be_a(Nova::API::Resource::Apportionment)
        expect(data.record.id).to eq(99)
        expect(data.record.name).to eq('foobar')
        expect(data.errors).to be_empty
      end
    end

    context 'when the response is an error' do
      context 'and the error is a string' do
        let(:model) { Nova::API::Resource::Apportionment.new(name: 'foobar') }
        let(:response) { double(:response, success?: false, parsed_response: { 'error' => 'foobarbaz' }) }

        it 'extracts the data from the httparty response object' do
          data = described_class.build(response, model)

          expect(data.success).to be_falsy
          expect(data.record).to be_a(Nova::API::Resource::Apportionment)
          expect(data.record.id).to be_nil
          expect(data.record.name).to eq('foobar')
          expect(data.errors).to match_array(['foobarbaz'])
        end
      end

      context 'and the error is an array' do
        let(:model) { Nova::API::Resource::Apportionment.new(name: 'foobar') }
        let(:response) { double(:response, success?: false, parsed_response: { 'errors' => ['foobarbaz', 'barfoobaz'] }) }

        it 'extracts the data from the httparty response object' do
          data = described_class.build(response, model)

          expect(data.success).to be_falsy
          expect(data.record).to be_a(Nova::API::Resource::Apportionment)
          expect(data.record.id).to be_nil
          expect(data.record.name).to eq('foobar')
          expect(data.errors).to match_array(['foobarbaz', 'barfoobaz'])
        end
      end
    end
  end
end
