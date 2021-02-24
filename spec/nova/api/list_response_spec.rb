RSpec.describe Nova::API::ListResponse do
  describe '.build' do
    context 'when the response is a success' do
      let(:response) do
        double(:response, success?: true, parsed_response: [
          { id: 99, name: 'abc', active: true, values: [{ id: 99, name: 'cba', active: true }, { id: 1, name: 'aaa', active: false }] },
          { id: 1, name: 'foobar', active: false, values: [{ id: 98, name: 'foo', active: false }, { id: 2, name: 'bar', active: false }] }
        ])
      end

      it 'extracts the data from the httparty response object' do
        data = described_class.build(response, Nova::API::Resource::Apportionment)

        expect(data.success).to be_truthy
        expect(data.records).to_not be_empty
        expect(data.records).to all(be_a(Nova::API::Resource::Apportionment))
        expect(data.errors).to be_empty
      end
    end

    context 'when the response is an error' do
      context 'and the error is a string' do
        let(:response) { double(:response, success?: false, parsed_response: { 'error' => 'foobarbaz' }) }

        it 'extracts the data from the httparty response object' do
          data = described_class.build(response, Nova::API::Resource::Apportionment)

          expect(data.success).to be_falsy
          expect(data.records).to be_nil
          expect(data.errors).to match_array(['foobarbaz'])
        end
      end

      context 'and the error is an array' do
        let(:response) { double(:response, success?: false, parsed_response: { 'errors' => ['foobarbaz', 'barfoobaz'] }) }

        it 'extracts the data from the httparty response object' do
          data = described_class.build(response, Nova::API::Resource::Apportionment)

          expect(data.success).to be_falsy
          expect(data.records).to be_nil
          expect(data.errors).to match_array(['foobarbaz', 'barfoobaz'])
        end
      end
    end
  end
end
