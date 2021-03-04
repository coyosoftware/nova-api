RSpec.describe Nova::API::Resource::Apportionment do
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
    it { is_expected.to have_attribute(:active, Dry::Types['strict.bool'].optional) }
    it { is_expected.to have_attribute(:values, Dry::Types['strict.array'].of(Nova::API::Resource::ApportionmentValue).optional) }
  end

  describe '.endpoint' do
    it 'returns the apportionment endpoint' do
      expect(described_class.endpoint).to eq('/api/apportionments')
    end
  end

  describe '.list' do
    let(:parameters) { { q: 'foobar' } }
    let(:data) do
      [
        { id: 99, name: 'abc', active: true, values: [{ id: 99, name: 'cba', active: true, apportionment_id: 99 }, { id: 1, name: 'aaa', active: false, apportionment_id: 99 }] },
        { id: 1, name: 'foobar', active: false, values: [{ id: 98, name: 'foo', active: false, apportionment_id: 1 }, { id: 2, name: 'bar', active: false, apportionment_id: 1 }] }
      ]
    end
    let(:response) { double(:response, success?: true, parsed_response: data) }

    subject { described_class.list(Nova::API::SearchParams::Apportionment.new parameters) }

    it 'issues a get to the apportionment list endpoint' do
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

        expect(response.records).to all(be_a(Nova::API::Resource::Apportionment))

        expect(response.records[0].id).to eq(data[0][:id])
        expect(response.records[0].name).to eq(data[0][:name])
        expect(response.records[0].active).to eq(data[0][:active])

        expect(response.records[0].values).to all(be_a(Nova::API::Resource::ApportionmentValue))

        expect(response.records[0].values[0].id).to eq(data[0][:values][0][:id])
        expect(response.records[0].values[0].name).to eq(data[0][:values][0][:name])
        expect(response.records[0].values[0].active).to eq(data[0][:values][0][:active])
        expect(response.records[0].values[0].apportionment_id).to eq(data[0][:values][0][:apportionment_id])
        expect(response.records[0].values[1].id).to eq(data[0][:values][1][:id])
        expect(response.records[0].values[1].name).to eq(data[0][:values][1][:name])
        expect(response.records[0].values[1].active).to eq(data[0][:values][1][:active])
        expect(response.records[0].values[1].apportionment_id).to eq(data[0][:values][1][:apportionment_id])

        expect(response.records[1].id).to eq(data[1][:id])
        expect(response.records[1].name).to eq(data[1][:name])
        expect(response.records[1].active).to eq(data[1][:active])
        expect(response.records[1].values[0].id).to eq(data[1][:values][0][:id])
        expect(response.records[1].values[0].name).to eq(data[1][:values][0][:name])
        expect(response.records[1].values[0].active).to eq(data[1][:values][0][:active])
        expect(response.records[1].values[0].apportionment_id).to eq(data[1][:values][0][:apportionment_id])
        expect(response.records[1].values[1].id).to eq(data[1][:values][1][:id])
        expect(response.records[1].values[1].name).to eq(data[1][:values][1][:name])
        expect(response.records[1].values[1].active).to eq(data[1][:values][1][:active])
        expect(response.records[1].values[1].apportionment_id).to eq(data[1][:values][1][:apportionment_id])
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

  describe '.create' do
    let(:name) { 'foobar' }
    let(:parameters) { { name: name } }
    let(:response) { double(:response, success?: true, parsed_response: { id: 99 }) }

    subject { described_class.create(parameters) }

    it 'issues a post to the apportionment create endpoint' do
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

      it 'returns the created apportionment' do
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

      it 'returns the errors' do
        response = subject

        expect(response.record).to be_a(described_class)
        expect(response.errors).to match_array(errors)
      end
    end
  end

  describe '.update' do
    let(:name) { 'foobar' }
    let(:parameters) { { name: name } }

    context 'when the id is not set' do
      it 'raises the missing id error' do
        expect { described_class.update(nil, parameters) }.to raise_error(Nova::API::MissingIdError, 'This operation requires an ID to be set')
      end
    end

    context 'when the id is set' do
      let(:id) { 99 }
      let(:response) { double(:response, success?: true, parsed_response: { id: 99 }) }

      subject { described_class.update(id, parameters) }

      it 'issues a patch to the apportionment update endpoint' do
        expect(described_class).to receive(:patch).with("#{described_class.endpoint}/#{id}", body: parameters, headers: authorization_header).and_return(response)

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

        it 'returns the updated apportionment' do
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

        it 'returns the errors' do
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

      it 'issues a delete to the apportionment delete endpoint' do
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

  describe '.reactivate' do
    context 'when the id is not set' do
      subject { described_class.reactivate(nil) }

      it 'raises the missing id error' do
        expect { subject }.to raise_error(Nova::API::MissingIdError, 'This operation requires an ID to be set')
      end
    end

    context 'when the id is set' do
      let(:id) { 99 }
      let(:response) { double(:response, success?: true, parsed_response: nil) }

      subject { described_class.reactivate(id) }

      it 'issues a patch to the apportionment reactivate endpoint' do
        expect(described_class).to receive(:patch).with("#{described_class.endpoint}/#{id}/reactivate", headers: authorization_header).and_return(response)

        subject
      end

      context 'with a successful response' do
        before do
          stub_request(:patch, "#{described_class.base_url}#{described_class.endpoint}/#{id}/reactivate").
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
          stub_request(:patch, "#{described_class.base_url}#{described_class.endpoint}/#{id}/reactivate").
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
    let(:name) { 'foobar' }
    let(:parameters) { { name: name, id: id } }

    subject { described_class.new(parameters) }

    it 'returns the apportionment endpoint' do
      expect(subject.endpoint).to eq("/api/apportionments/#{id}")
    end
  end

  describe '#save' do
    let(:name) { 'foobar' }
    let(:parameters) { { name: name } }

    context 'when the id is not set' do
      let(:response) { double(:response, success?: true, parsed_response: { id: 99 }) }

      subject { described_class.new(parameters) }

      it 'issues a post to the apportionment create endpoint' do
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

        it 'returns the created apportionment' do
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

        it 'returns the apportionment with its errors' do
          response = subject.save

          expect(response.record).to be_a(described_class)
          expect(response.errors).to match_array(errors)
        end
      end
    end

    context 'when the id is set' do
      let(:id) { 99 }
      let(:response) { double(:response, success?: true, parsed_response: nil) }

      subject { described_class.new(parameters.merge(id: id)) }

      it 'issues a patch to the apportionment update endpoint' do
        expect(described_class).to receive(:patch).with("#{described_class.endpoint}/#{id}", body: parameters, headers: authorization_header).and_return(response)

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

        it 'returns the updated apportionment' do
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

        it 'returns the apportionment with its errors' do
          response = subject.save

          expect(response.record).to be_a(described_class)
          expect(response.errors).to match_array(errors)
        end
      end
    end
  end

  describe '#update' do
    let(:name) { 'foobar' }
    let(:parameters) { { name: name } }

    context 'when the id is not set' do
      subject { described_class.new(parameters) }

      it 'raises the missing id error' do
        expect { subject.update }.to raise_error(Nova::API::MissingIdError, 'This operation requires an ID to be set')
      end
    end

    context 'when the id is set' do
      let(:id) { 99 }
      let(:response) { double(:response, success?: true, parsed_response: { id: 99 }) }

      subject { described_class.new(parameters.merge(id: id)) }

      it 'issues a patch to the apportionment update endpoint' do
        expect(described_class).to receive(:patch).with("#{described_class.endpoint}/#{id}", body: parameters, headers: authorization_header).and_return(response)

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

        it 'returns the updated apportionment' do
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

        it 'returns the apportionment with its errors' do
          response = subject.update

          expect(response.record).to be_a(described_class)
          expect(response.errors).to match_array(errors)
        end
      end
    end
  end

  describe '#destroy' do
    let(:name) { 'foobar' }
    let(:parameters) { { name: name } }

    context 'when the id is not set' do
      subject { described_class.new(parameters) }

      it 'raises the missing id error' do
        expect { subject.destroy }.to raise_error(Nova::API::MissingIdError, 'This operation requires an ID to be set')
      end
    end

    context 'when the id is set' do
      let(:id) { 99 }
      let(:response) { double(:response, success?: true, parsed_response: nil) }

      subject { described_class.new(parameters.merge(id: id)) }

      it 'issues a delete to the apportionment delete endpoint' do
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

  describe '#reactivate' do
    let(:name) { 'foobar' }
    let(:parameters) { { name: name } }

    context 'when the id is not set' do
      subject { described_class.new(parameters) }

      it 'raises the missing id error' do
        expect { subject.reactivate }.to raise_error(Nova::API::MissingIdError, 'This operation requires an ID to be set')
      end
    end

    context 'when the id is set' do
      let(:id) { 99 }
      let(:response) { double(:response, success?: true, parsed_response: nil) }

      subject { described_class.new(parameters.merge(id: id)) }

      it 'issues a patch to the apportionment reactivate endpoint' do
        expect(described_class).to receive(:patch).with("#{described_class.endpoint}/#{id}/reactivate", headers: authorization_header).and_return(response)

        subject.reactivate
      end

      context 'with a successful response' do
        before do
          stub_request(:patch, "#{described_class.base_url}#{described_class.endpoint}/#{id}/reactivate").
            to_return(status: 200, body: nil)
        end

        it 'returns the response object' do
          expect(subject.reactivate).to be_a(Nova::API::Response)
        end

        it 'returns no error' do
          response = subject.reactivate

          expect(response.errors).to be_empty
        end

        it 'returns no record' do
          response = subject.reactivate

          expect(response.record).to be_nil
        end
      end

      context 'with an error response' do
        let(:errors) { ['foo', 'bar'] }

        before do
          stub_request(:patch, "#{described_class.base_url}#{described_class.endpoint}/#{id}/reactivate").
            to_return(status: 400, body: JSON.generate({ errors: errors }))
        end

        it 'returns the response object' do
          expect(subject.reactivate).to be_a(Nova::API::Response)
        end

        it 'returns the errors' do
          response = subject.reactivate

          expect(response.errors).to match_array(errors)
        end

        it 'returns no record' do
          response = subject.reactivate

          expect(response.record).to be_nil
        end
      end
    end
  end
end
