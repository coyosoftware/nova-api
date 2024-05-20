RSpec.describe Nova::API::Resource::Webhook do
  before(:all) do
    Nova::API.configure do |config|
      config.subdomain = 'foobar'
      config.api_key = 'foo-bar'
    end
  end

  describe 'attributes' do
    subject { described_class }

    it { is_expected.to have_attribute(:id, Dry::Types['coercible.integer'].optional) }
    it { is_expected.to have_attribute(:events, Dry::Types['strict.array'].of(Dry::Types['coercible.string'])) }
    it { is_expected.to have_attribute(:url, Dry::Types['coercible.string']) }
  end

  describe '.endpoint' do
    it 'returns the webhook endpoint' do
      expect(described_class.endpoint).to eq('/api/webhooks')
    end
  end

  describe '.create' do
    let(:events) { %w[company.create company.update] }
    let(:url) { 'https://my.custom.webhook' }
    let(:parameters) { { events: events, url: url } }
    let(:response) { double(:response, success?: true, parsed_response: { id: 99 }, code: 201) }

    subject { described_class.create(parameters) }

    it 'issues a post to the webhook create endpoint' do
      expect(HTTParty).to receive(:post).with("#{described_class.base_url}#{described_class.endpoint}", body: parameters, headers: authorization_header, format: :json).and_return(response)

      subject
    end

    context 'with a successful response' do
      let(:id) { 99 }

      before do
        stub_request(:post, "#{described_class.base_url}#{described_class.endpoint}").to_return(status: 201, body: JSON.generate({ id: id }))
      end

      it 'returns the response object' do
        expect(subject).to be_a(Nova::API::Response)
      end

      it 'returns no error' do
        response = subject

        expect(response.errors).to be_empty
      end

      it 'returns the created webhook' do
        response = subject

        expect(response.record).to be_a(described_class)
        expect(response.record.events).to eq(events)
        expect(response.record.url).to eq(url)
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

      it 'returns the webhook with its errors' do
        response = subject

        expect(response.record).to be_a(described_class)
        expect(response.errors).to match_array(errors)
      end
    end
  end

  describe '.update' do
    let(:events) { %w[company.create company.update] }
    let(:url) { 'https://my.custom.webhook' }
    let(:parameters) { { events: events, url: url } }

    context 'when the id is not set' do
      it 'raises the missing id error' do
        expect { described_class.update(nil, parameters) }.to raise_error(Nova::API::MissingIdError, 'This operation requires an ID to be set')
      end
    end

    context 'when the id is set' do
      let(:id) { 99 }
      let(:response) { double(:response, success?: true, parsed_response: { id: 99 }, code: 200) }

      subject { described_class.update(id, parameters) }

      it 'issues a patch to the webhook update endpoint' do
        expect(HTTParty).to receive(:patch).with("#{described_class.base_url}#{described_class.endpoint}/#{id}", body: parameters, headers: authorization_header, format: :json).and_return(response)

        subject
      end

      context 'with a successful response' do
        before do
          stub_request(:patch, "#{described_class.base_url}#{described_class.endpoint}/#{id}").to_return(status: 200, body: nil)
        end

        it 'returns the response object' do
          expect(subject).to be_a(Nova::API::Response)
        end

        it 'returns no error' do
          response = subject

          expect(response.errors).to be_empty
        end

        it 'returns the updated webhook' do
          response = subject

          expect(response.record).to be_a(described_class)
          expect(response.record.events).to eq(events)
          expect(response.record.url).to eq(url)
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

        it 'returns the webhook with its errors' do
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
      let(:response) { double(:response, success?: true, parsed_response: nil, code: 200) }

      subject { described_class.destroy(id) }

      it 'issues a delete to the webhook delete endpoint' do
        expect(HTTParty).to receive(:delete).with("#{described_class.base_url}#{described_class.endpoint}/#{id}", headers: authorization_header, format: :json).and_return(response)

        subject
      end

      context 'with a successful response' do
        before do
          stub_request(:delete, "#{described_class.base_url}#{described_class.endpoint}/#{id}").to_return(status: 200, body: nil)
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
          stub_request(:delete, "#{described_class.base_url}#{described_class.endpoint}/#{id}").to_return(status: 400, body: JSON.generate({ errors: errors }))
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

  describe '.restore' do
    context 'when the id is not set' do
      subject { described_class.restore(nil) }

      it 'raises the missing id error' do
        expect { subject }.to raise_error(Nova::API::MissingIdError, 'This operation requires an ID to be set')
      end
    end

    context 'when the id is set' do
      let(:id) { 99 }
      let(:response) { double(:response, success?: true, parsed_response: nil, code: 200) }

      subject { described_class.restore(id) }

      it 'issues a patch to the webhook restore endpoint' do
        expect(HTTParty).to receive(:patch).with("#{described_class.base_url}#{described_class.endpoint}/#{id}/restore", headers: authorization_header, format: :json).and_return(response)

        subject
      end

      context 'with a successful response' do
        before do
          stub_request(:patch, "#{described_class.base_url}#{described_class.endpoint}/#{id}/restore").to_return(status: 200, body: nil)
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
          stub_request(:patch, "#{described_class.base_url}#{described_class.endpoint}/#{id}/restore").to_return(status: 400, body: JSON.generate({ errors: errors }))
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
    let(:events) { %w[company.create company.update] }
    let(:url) { 'https://my.custom.webhook' }
    let(:parameters) { { events: events, url: url, id: id } }

    subject { described_class.new(parameters) }

    it 'returns the webhook endpoint' do
      expect(subject.endpoint).to eq("/api/webhooks/#{id}")
    end
  end

  describe '#save' do
    let(:events) { %w[company.create company.update] }
    let(:url) { 'https://my.custom.webhook' }
    let(:parameters) { { events: events, url: url } }

    context 'when the id is not set' do
      let(:response) { double(:response, success?: true, parsed_response: { id: 99 }, code: 201) }

      subject { described_class.new(parameters) }

      it 'issues a post to the webhook create endpoint' do
        expect(HTTParty).to receive(:post).with("#{described_class.base_url}#{described_class.endpoint}", body: parameters, headers: authorization_header, format: :json).and_return(response)

        subject.save
      end

      context 'with a successful response' do
        let(:id) { 99 }

        before do
          stub_request(:post, "#{described_class.base_url}#{described_class.endpoint}").to_return(status: 201, body: JSON.generate({ id: id }))
        end

        it 'returns the response object' do
          expect(subject.save).to be_a(Nova::API::Response)
        end

        it 'returns no error' do
          response = subject.save

          expect(response.errors).to be_empty
        end

        it 'returns the created webhook' do
          response = subject.save

          expect(response.record).to be_a(described_class)
          expect(response.record.events).to eq(events)
          expect(response.record.url).to eq(url)
          expect(response.record.id).to eq(id)
        end
      end

      context 'with an error response' do
        let(:errors) { ['foo', 'bar'] }

        before do
          stub_request(:post, "#{described_class.base_url}#{described_class.endpoint}").to_return(status: 400, body: JSON.generate({ errors: errors }))
        end

        it 'returns the response object' do
          expect(subject.save).to be_a(Nova::API::Response)
        end

        it 'returns the webhook with its errors' do
          response = subject.save

          expect(response.record).to be_a(described_class)
          expect(response.errors).to match_array(errors)
        end
      end
    end

    context 'when the id is set' do
      let(:id) { 99 }
      let(:response) { double(:response, success?: true, parsed_response: nil, code: 200) }

      subject { described_class.new(parameters.merge(id: id)) }

      it 'issues a patch to the webhook update endpoint' do
        expect(HTTParty).to receive(:patch).with("#{described_class.base_url}#{described_class.endpoint}/#{id}", body: parameters, headers: authorization_header, format: :json).and_return(response)

        subject.save
      end

      context 'with a successful response' do
        before do
          stub_request(:patch, "#{described_class.base_url}#{described_class.endpoint}/#{id}").to_return(status: 200, body: nil)
        end

        it 'returns the response object' do
          expect(subject.save).to be_a(Nova::API::Response)
        end

        it 'returns no error' do
          response = subject.save

          expect(response.errors).to be_empty
        end

        it 'returns the updated webhook' do
          response = subject.save

          expect(response.record).to be_a(described_class)
          expect(response.record.events).to eq(events)
          expect(response.record.url).to eq(url)
          expect(response.record.id).to eq(id)
        end
      end

      context 'with an error response' do
        let(:errors) { ['foo', 'bar'] }

        before do
          stub_request(:patch, "#{described_class.base_url}#{described_class.endpoint}/#{id}").to_return(status: 400, body: JSON.generate({ errors: errors }))
        end

        it 'returns the response object' do
          expect(subject.save).to be_a(Nova::API::Response)
        end

        it 'returns the webhook with its errors' do
          response = subject.save

          expect(response.record).to be_a(described_class)
          expect(response.errors).to match_array(errors)
        end
      end
    end
  end

  describe '#update' do
    let(:events) { %w[company.create company.update] }
    let(:url) { 'https://my.custom.webhook' }
    let(:parameters) { { events: events, url: url } }

    context 'when the id is not set' do
      subject { described_class.new(parameters) }

      it 'raises the missing id error' do
        expect { subject.update }.to raise_error(Nova::API::MissingIdError, 'This operation requires an ID to be set')
      end
    end

    context 'when the id is set' do
      let(:id) { 99 }
      let(:response) { double(:response, success?: true, parsed_response: { id: 99 }, code: 200) }

      subject { described_class.new(parameters.merge(id: id)) }

      it 'issues a patch to the webhook update endpoint' do
        expect(HTTParty).to receive(:patch).with("#{described_class.base_url}#{described_class.endpoint}/#{id}", body: parameters, headers: authorization_header, format: :json).and_return(response)

        subject.update
      end

      context 'with a successful response' do
        before do
          stub_request(:patch, "#{described_class.base_url}#{described_class.endpoint}/#{id}").to_return(status: 200, body: nil)
        end

        it 'returns the response object' do
          expect(subject.update).to be_a(Nova::API::Response)
        end

        it 'returns no error' do
          response = subject.update

          expect(response.errors).to be_empty
        end

        it 'returns the updated webhook' do
          response = subject.update

          expect(response.record).to be_a(described_class)
          expect(response.record.events).to eq(events)
          expect(response.record.url).to eq(url)
          expect(response.record.id).to eq(id)
        end
      end

      context 'with an error response' do
        let(:errors) { ['foo', 'bar'] }

        before do
          stub_request(:patch, "#{described_class.base_url}#{described_class.endpoint}/#{id}").to_return(status: 400, body: JSON.generate({ errors: errors }))
        end

        it 'returns the response object' do
          expect(subject.update).to be_a(Nova::API::Response)
        end

        it 'returns the webhook with its errors' do
          response = subject.update

          expect(response.record).to be_a(described_class)
          expect(response.errors).to match_array(errors)
        end
      end
    end
  end

  describe '#destroy' do
    let(:events) { %w[company.create company.update] }
    let(:url) { 'https://my.custom.webhook' }
    let(:parameters) { { events: events, url: url } }

    context 'when the id is not set' do
      subject { described_class.new(parameters) }

      it 'raises the missing id error' do
        expect { subject.destroy }.to raise_error(Nova::API::MissingIdError, 'This operation requires an ID to be set')
      end
    end

    context 'when the id is set' do
      let(:id) { 99 }
      let(:response) { double(:response, success?: true, parsed_response: nil, code: 200) }

      subject { described_class.new(parameters.merge(id: id)) }

      it 'issues a delete to the webhook delete endpoint' do
        expect(HTTParty).to receive(:delete).with("#{described_class.base_url}#{described_class.endpoint}/#{id}", headers: authorization_header, format: :json).and_return(response)

        subject.destroy
      end

      context 'with a successful response' do
        before do
          stub_request(:delete, "#{described_class.base_url}#{described_class.endpoint}/#{id}").to_return(status: 200, body: nil)
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
          stub_request(:delete, "#{described_class.base_url}#{described_class.endpoint}/#{id}").to_return(status: 400, body: JSON.generate({ errors: errors }))
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

  describe '#restore' do
    let(:events) { %w[company.create company.update] }
    let(:url) { 'https://my.custom.webhook' }
    let(:parameters) { { events: events, url: url } }

    context 'when the id is not set' do
      subject { described_class.new(parameters) }

      it 'raises the missing id error' do
        expect { subject.restore }.to raise_error(Nova::API::MissingIdError, 'This operation requires an ID to be set')
      end
    end

    context 'when the id is set' do
      let(:id) { 99 }
      let(:response) { double(:response, success?: true, parsed_response: nil, code: 200) }

      subject { described_class.new(parameters.merge(id: id)) }

      it 'issues a patch to the webhook restore endpoint' do
        expect(HTTParty).to receive(:patch).with("#{described_class.base_url}#{described_class.endpoint}/#{id}/restore", headers: authorization_header, format: :json).and_return(response)

        subject.restore
      end

      context 'with a successful response' do
        before do
          stub_request(:patch, "#{described_class.base_url}#{described_class.endpoint}/#{id}/restore").to_return(status: 200, body: nil)
        end

        it 'returns the response object' do
          expect(subject.restore).to be_a(Nova::API::Response)
        end

        it 'returns no error' do
          response = subject.restore

          expect(response.errors).to be_empty
        end

        it 'returns no record' do
          response = subject.restore

          expect(response.record).to be_nil
        end
      end

      context 'with an error response' do
        let(:errors) { ['foo', 'bar'] }

        before do
          stub_request(:patch, "#{described_class.base_url}#{described_class.endpoint}/#{id}/restore").to_return(status: 400, body: JSON.generate({ errors: errors }))
        end

        it 'returns the response object' do
          expect(subject.restore).to be_a(Nova::API::Response)
        end

        it 'returns the errors' do
          response = subject.restore

          expect(response.errors).to match_array(errors)
        end

        it 'returns no record' do
          response = subject.restore

          expect(response.record).to be_nil
        end
      end
    end
  end
end
