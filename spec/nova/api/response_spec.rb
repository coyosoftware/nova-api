RSpec.describe Nova::API::Response do
  describe 'attributes' do
    subject { described_class }

    it { is_expected.to have_attribute(:record, Dry::Types['nominal.any']) }
    it { is_expected.to have_attribute(:errors, Dry::Types['strict.array'].of(Dry::Types['coercible.string'])) }
    it { is_expected.to have_attribute(:success, Dry::Types['strict.bool']) }
    it { is_expected.to have_attribute(:status, Dry::Types['coercible.integer']) }
  end

  describe '.build' do
    context 'when the response is a success' do
      let(:model) { Nova::API::Resource::Apportionment.new(name: 'foobar') }
      let(:response) { double(:response, success?: true, parsed_response: { 'id' => 99 }, code: 200) }

      it 'extracts the data from the httparty response object' do
        data = described_class.build(response, model)

        expect(data.status).to eq(200)
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
        let(:response) { double(:response, success?: false, parsed_response: { 'error' => 'foobarbaz' }, code: 400) }

        it 'extracts the data from the httparty response object' do
          data = described_class.build(response, model)

          expect(data.status).to eq(400)
          expect(data.success).to be_falsy
          expect(data.record).to be_a(Nova::API::Resource::Apportionment)
          expect(data.record.id).to be_nil
          expect(data.record.name).to eq('foobar')
          expect(data.errors).to match_array(['foobarbaz'])
        end
      end

      context 'and the error is an array' do
        let(:model) { Nova::API::Resource::Apportionment.new(name: 'foobar') }
        let(:response) { double(:response, success?: false, parsed_response: { 'errors' => ['foobarbaz', 'barfoobaz'] }, code: '422') }

        it 'extracts the data from the httparty response object' do
          data = described_class.build(response, model)

          expect(data.status).to eq(422)
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
