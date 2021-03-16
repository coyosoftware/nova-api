RSpec.describe Nova::API::ListResponse do
  describe 'attributes' do
    subject { described_class }

    it { is_expected.to have_attribute(:records, Dry::Types['strict.array'].of(Dry::Types['nominal.any']).optional) }
    it { is_expected.to have_attribute(:errors, Dry::Types['strict.array'].of(Dry::Types['coercible.string'])) }
    it { is_expected.to have_attribute(:success, Dry::Types['strict.bool']) }
    it { is_expected.to have_attribute(:status, Dry::Types['coercible.integer']) }
  end

  describe '.build' do
    context 'when the response is a success' do
      let(:response) do
        double(:response, success?: true, parsed_response: [
          { id: 99, name: 'abc', active: true, values: [{ id: 99, name: 'cba', active: true }, { id: 1, name: 'aaa', active: false }] },
          { id: 1, name: 'foobar', active: false, values: [{ id: 98, name: 'foo', active: false }, { id: 2, name: 'bar', active: false }] }
        ], code: 200)
      end

      it 'extracts the data from the httparty response object' do
        data = described_class.build(response, Nova::API::Resource::Apportionment)

        expect(data.success).to be_truthy
        expect(data.status).to eq(200)
        expect(data.records).to_not be_empty
        expect(data.records).to all(be_a(Nova::API::Resource::Apportionment))
        expect(data.errors).to be_empty
      end
    end

    context 'when the response is an error' do
      context 'and the error is a string' do
        let(:response) { double(:response, success?: false, parsed_response: { 'error' => 'foobarbaz' }, code: 400) }

        it 'extracts the data from the httparty response object' do
          data = described_class.build(response, Nova::API::Resource::Apportionment)

          expect(data.success).to be_falsy
          expect(data.status).to eq(400)
          expect(data.records).to be_nil
          expect(data.errors).to match_array(['foobarbaz'])
        end
      end

      context 'and the error is an array' do
        let(:response) { double(:response, success?: false, parsed_response: { 'errors' => ['foobarbaz', 'barfoobaz'] }, code: '422') }

        it 'extracts the data from the httparty response object' do
          data = described_class.build(response, Nova::API::Resource::Apportionment)

          expect(data.success).to be_falsy
          expect(data.status).to eq(422)
          expect(data.records).to be_nil
          expect(data.errors).to match_array(['foobarbaz', 'barfoobaz'])
        end
      end
    end
  end
end
