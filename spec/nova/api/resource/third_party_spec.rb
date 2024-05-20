RSpec.describe Nova::API::Resource::ThirdParty do
  before(:all) do
    Nova::API.configure do |config|
      config.subdomain = 'foobar'
      config.api_key = 'foo-bar'
    end
  end

  describe 'attributes' do
    subject { described_class }

    it { is_expected.to have_attribute(:id, Dry::Types['coercible.integer'].optional) }
    it { is_expected.to have_attribute(:trading_name, Dry::Types['coercible.string']) }
    it { is_expected.to have_attribute(:identification, Dry::Types['coercible.string'].optional) }
    it { is_expected.to have_attribute(:address, Dry::Types['coercible.string'].optional) }
    it { is_expected.to have_attribute(:phone, Dry::Types['coercible.string'].optional) }
    it { is_expected.to have_attribute(:social_reason, Dry::Types['coercible.string'].optional) }
    it { is_expected.to have_attribute(:municipal_inscription, Dry::Types['coercible.string'].optional) }
    it { is_expected.to have_attribute(:state_inscription, Dry::Types['coercible.string'].optional) }
    it { is_expected.to have_attribute(:email, Dry::Types['coercible.string'].optional) }
    it { is_expected.to have_attribute(:notes, Dry::Types['coercible.string'].optional) }
    it { is_expected.to have_attribute(:supplier, Dry::Types['strict.bool'].optional) }
    it { is_expected.to have_attribute(:customer, Dry::Types['strict.bool'].optional) }
    it { is_expected.to have_attribute(:retention, Dry::Types['strict.bool'].optional) }
    it { is_expected.to have_attribute(:whatsapp, Dry::Types['coercible.string'].optional) }
    it { is_expected.to have_attribute(:twitter, Dry::Types['coercible.string'].optional) }
    it { is_expected.to have_attribute(:facebook, Dry::Types['coercible.string'].optional) }
    it { is_expected.to have_attribute(:linkedin, Dry::Types['coercible.string'].optional) }
    it { is_expected.to have_attribute(:google, Dry::Types['coercible.string'].optional) }
    it { is_expected.to have_attribute(:instagram, Dry::Types['coercible.string'].optional) }
    it { is_expected.to have_attribute(:site, Dry::Types['coercible.string'].optional) }
    it { is_expected.to have_attribute(:csll, Dry::Types['coercible.float'].optional) }
    it { is_expected.to have_attribute(:pis, Dry::Types['coercible.float'].optional) }
    it { is_expected.to have_attribute(:cofins, Dry::Types['coercible.float'].optional) }
    it { is_expected.to have_attribute(:irpj, Dry::Types['coercible.float'].optional) }
    it { is_expected.to have_attribute(:values_past, Dry::Types['coercible.float'].optional) }
  end

  describe '.endpoint' do
    it 'returns the third party endpoint' do
      expect(described_class.endpoint).to eq('/api/third_parties')
    end
  end

  describe '.list' do
    let(:parameters) { { q: 'foobar' } }
    let(:data) do
      [
        { id: 103, trading_name: 'Digitized encompassing secured line', supplier: true, customer: false },
        { id: 102, trading_name: 'Distributed multimedia matrices', supplier: false, customer: true }
      ]
    end
    let(:response) { double(:response, success?: true, parsed_response: data, code: 200) }

    subject { described_class.list(Nova::API::SearchParams::ThirdParty.new parameters) }

    it 'issues a get to the third party list endpoint' do
      expect(HTTParty).to receive(:get).with("#{described_class.base_url}#{described_class.endpoint}", query: parameters, headers: authorization_header, format: :json).and_return(response)

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

        expect(response.records).to all(be_a(Nova::API::Resource::ThirdParty))

        expect(response.records[0].id).to eq(data[0][:id])
        expect(response.records[0].trading_name).to eq(data[0][:trading_name])
        expect(response.records[0].supplier).to eq(data[0][:supplier])
        expect(response.records[0].customer).to eq(data[0][:customer])

        expect(response.records[1].id).to eq(data[1][:id])
        expect(response.records[1].trading_name).to eq(data[1][:trading_name])
        expect(response.records[1].supplier).to eq(data[1][:supplier])
        expect(response.records[1].customer).to eq(data[1][:customer])
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

  describe '.suppliers' do
    let(:parameters) { { q: 'foobar' } }
    let(:data) do
      [
        { id: 103, trading_name: 'Digitized encompassing secured line', supplier: true, customer: true },
        { id: 102, trading_name: 'Distributed multimedia matrices', supplier: true, customer: true }
      ]
    end
    let(:response) { double(:response, success?: true, parsed_response: data, code: 200) }

    subject { described_class.suppliers(Nova::API::SearchParams::ThirdParty.new parameters) }

    it 'issues a get to the third party suppliers endpoint' do
      expect(HTTParty).to receive(:get).with("#{described_class.base_url}/api/suppliers", query: parameters, headers: authorization_header, format: :json).and_return(response)

      subject
    end

    context 'with a successful response' do
      before do
        stub_request(:get, "#{described_class.base_url}/api/suppliers").with(query: parameters).
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

        expect(response.records).to all(be_a(Nova::API::Resource::ThirdParty))

        expect(response.records[0].id).to eq(data[0][:id])
        expect(response.records[0].trading_name).to eq(data[0][:trading_name])
        expect(response.records[0].supplier).to eq(data[0][:supplier])
        expect(response.records[0].customer).to eq(data[0][:customer])

        expect(response.records[1].id).to eq(data[1][:id])
        expect(response.records[1].trading_name).to eq(data[1][:trading_name])
        expect(response.records[1].supplier).to eq(data[1][:supplier])
        expect(response.records[1].customer).to eq(data[1][:customer])
      end
    end

    context 'with an error response' do
      let(:errors) { ['foo', 'bar'] }

      before do
        stub_request(:get, "#{described_class.base_url}/api/suppliers").with(query: parameters).
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

  describe '.customers' do
    let(:parameters) { { q: 'foobar' } }
    let(:data) do
      [
        { id: 103, trading_name: 'Digitized encompassing secured line', supplier: true, customer: true },
        { id: 102, trading_name: 'Distributed multimedia matrices', supplier: true, customer: true }
      ]
    end
    let(:response) { double(:response, success?: true, parsed_response: data, code: 200) }

    subject { described_class.customers(Nova::API::SearchParams::ThirdParty.new parameters) }

    it 'issues a get to the third party customer endpoint' do
      expect(HTTParty).to receive(:get).with("#{described_class.base_url}/api/customers", query: parameters, headers: authorization_header, format: :json).and_return(response)

      subject
    end

    context 'with a successful response' do
      before do
        stub_request(:get, "#{described_class.base_url}/api/customers").with(query: parameters).
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

        expect(response.records).to all(be_a(Nova::API::Resource::ThirdParty))

        expect(response.records[0].id).to eq(data[0][:id])
        expect(response.records[0].trading_name).to eq(data[0][:trading_name])
        expect(response.records[0].supplier).to eq(data[0][:supplier])
        expect(response.records[0].customer).to eq(data[0][:customer])

        expect(response.records[1].id).to eq(data[1][:id])
        expect(response.records[1].trading_name).to eq(data[1][:trading_name])
        expect(response.records[1].supplier).to eq(data[1][:supplier])
        expect(response.records[1].customer).to eq(data[1][:customer])
      end
    end

    context 'with an error response' do
      let(:errors) { ['foo', 'bar'] }

      before do
        stub_request(:get, "#{described_class.base_url}/api/customers").with(query: parameters).
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
    let(:trading_name) { 'foobar' }
    let(:identification) { '70.298.607/0001-85' }
    let(:address) { 'Rua Foo Bar' }
    let(:phone) { '551232323435' }
    let(:social_reason) { 'Foo Bar Eireli' }
    let(:municipal_inscription) { 'ISENTO' }
    let(:state_inscription) { 'ISENTO' }
    let(:email) { 'foo@bar.com' }
    let(:notes) { 'Obs' }
    let(:supplier) { true }
    let(:customer) { true }
    let(:retention) { true }
    let(:whatsapp) { '5512998779605' }
    let(:twitter) { 'https://twitter.com/foobar' }
    let(:facebook) { 'https://facebook.com/foobar' }
    let(:linkedin) { 'https://linkedi.com/foobar' }
    let(:google) { 'https://google.com/foobar' }
    let(:instagram) { 'https://instagram.com/foobar' }
    let(:site) { 'https://foobar.com' }
    let(:csll) { BigDecimal('0.15') }
    let(:pis) { BigDecimal('0.16') }
    let(:cofins) { BigDecimal('0.17') }
    let(:irpj) { BigDecimal('0.22') }
    let(:values_past) { BigDecimal('19999.99') }
    let(:parameters) do
      {
        trading_name: trading_name, identification: identification, address: address, phone: phone, social_reason: social_reason,
        municipal_inscription: municipal_inscription, state_inscription: state_inscription, email: email, notes: notes,
        supplier: supplier, customer: customer, retention: retention, whatsapp: whatsapp, twitter: twitter, facebook: facebook,
        linkedin: linkedin, google: google, instagram: instagram, site: site, csll: csll, pis: pis, cofins: cofins, irpj: irpj, values_past: values_past
      }
    end
    let(:response) { double(:response, success?: true, parsed_response: { id: 99 }, code: 201) }

    subject { described_class.create(parameters) }

    it 'issues a post to the third party create endpoint' do
      expect(HTTParty).to receive(:post).with("#{described_class.base_url}#{described_class.endpoint}", body: parameters, headers: authorization_header, format: :json).and_return(response)

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

      it 'returns the created third party' do
        response = subject

        expect(response.record).to be_a(described_class)

        parameters.keys.each do |field|
          expect(response.record.send(field.to_sym)).to eq(parameters[field])
        end
        
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

      it 'returns the third party with its errors' do
        response = subject

        expect(response.record).to be_a(described_class)
        expect(response.errors).to match_array(errors)
      end
    end
  end

  describe '.update' do
    let(:trading_name) { 'foobar' }
    let(:identification) { '70.298.607/0001-85' }
    let(:address) { 'Rua Foo Bar' }
    let(:phone) { '551232323435' }
    let(:social_reason) { 'Foo Bar Eireli' }
    let(:municipal_inscription) { 'ISENTO' }
    let(:state_inscription) { 'ISENTO' }
    let(:email) { 'foo@bar.com' }
    let(:notes) { 'Obs' }
    let(:supplier) { true }
    let(:customer) { true }
    let(:retention) { true }
    let(:whatsapp) { '5512998779605' }
    let(:twitter) { 'https://twitter.com/foobar' }
    let(:facebook) { 'https://facebook.com/foobar' }
    let(:linkedin) { 'https://linkedi.com/foobar' }
    let(:google) { 'https://google.com/foobar' }
    let(:instagram) { 'https://instagram.com/foobar' }
    let(:site) { 'https://foobar.com' }
    let(:csll) { BigDecimal('0.15') }
    let(:pis) { BigDecimal('0.16') }
    let(:cofins) { BigDecimal('0.17') }
    let(:irpj) { BigDecimal('0.22') }
    let(:values_past) { BigDecimal('19999.99') }
    let(:parameters) do
      {
        trading_name: trading_name, identification: identification, address: address, phone: phone, social_reason: social_reason,
        municipal_inscription: municipal_inscription, state_inscription: state_inscription, email: email, notes: notes,
        supplier: supplier, customer: customer, retention: retention, whatsapp: whatsapp, twitter: twitter, facebook: facebook,
        linkedin: linkedin, google: google, instagram: instagram, site: site, csll: csll, pis: pis, cofins: cofins, irpj: irpj, values_past: values_past
      }
    end

    context 'when the id is not set' do
      it 'raises the missing id error' do
        expect { described_class.update(nil, parameters) }.to raise_error(Nova::API::MissingIdError, 'This operation requires an ID to be set')
      end
    end

    context 'when the id is set' do
      let(:id) { 99 }
      let(:response) { double(:response, success?: true, parsed_response: { id: 99 }, code: 200) }

      subject { described_class.update(id, parameters) }

      it 'issues a patch to the third party update endpoint' do
        expect(HTTParty).to receive(:patch).with("#{described_class.base_url}#{described_class.endpoint}/#{id}", body: parameters, headers: authorization_header, format: :json).and_return(response)

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

        it 'returns the updated third party' do
          response = subject

          expect(response.record).to be_a(described_class)

          parameters.keys.each do |field|
            expect(response.record.send(field.to_sym)).to eq(parameters[field])
          end
          
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

        it 'returns the third party with its errors' do
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

      it 'issues a delete to the third party delete endpoint' do
        expect(HTTParty).to receive(:delete).with("#{described_class.base_url}#{described_class.endpoint}/#{id}", headers: authorization_header, format: :json).and_return(response)

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

  describe '#save' do
    let(:trading_name) { 'foobar' }
    let(:identification) { '70.298.607/0001-85' }
    let(:address) { 'Rua Foo Bar' }
    let(:phone) { '551232323435' }
    let(:social_reason) { 'Foo Bar Eireli' }
    let(:municipal_inscription) { 'ISENTO' }
    let(:state_inscription) { 'ISENTO' }
    let(:email) { 'foo@bar.com' }
    let(:notes) { 'Obs' }
    let(:supplier) { true }
    let(:customer) { true }
    let(:retention) { true }
    let(:whatsapp) { '5512998779605' }
    let(:twitter) { 'https://twitter.com/foobar' }
    let(:facebook) { 'https://facebook.com/foobar' }
    let(:linkedin) { 'https://linkedi.com/foobar' }
    let(:google) { 'https://google.com/foobar' }
    let(:instagram) { 'https://instagram.com/foobar' }
    let(:site) { 'https://foobar.com' }
    let(:csll) { BigDecimal('0.15') }
    let(:pis) { BigDecimal('0.16') }
    let(:cofins) { BigDecimal('0.17') }
    let(:irpj) { BigDecimal('0.22') }
    let(:values_past) { BigDecimal('19999.99') }
    let(:parameters) do
      {
        trading_name: trading_name, identification: identification, address: address, phone: phone, social_reason: social_reason,
        municipal_inscription: municipal_inscription, state_inscription: state_inscription, email: email, notes: notes,
        supplier: supplier, customer: customer, retention: retention, whatsapp: whatsapp, twitter: twitter, facebook: facebook,
        linkedin: linkedin, google: google, instagram: instagram, site: site, csll: csll, pis: pis, cofins: cofins, irpj: irpj, values_past: values_past
      }
    end

    context 'when the id is not set' do
      let(:response) { double(:response, success?: true, parsed_response: { id: 99 }, code: 201) }

      subject { described_class.new(parameters) }

      it 'issues a post to the third party create endpoint' do
        expect(HTTParty).to receive(:post).with("#{described_class.base_url}#{described_class.endpoint}", body: parameters, headers: authorization_header, format: :json).and_return(response)

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

        it 'returns the created third party' do
          response = subject.save

          expect(response.record).to be_a(described_class)

          parameters.keys.each do |field|
            expect(response.record.send(field.to_sym)).to eq(parameters[field])
          end
          
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
      let(:response) { double(:response, success?: true, parsed_response: nil, code: 200) }

      subject { described_class.new(parameters.merge(id: id)) }

      it 'issues a patch to the third party update endpoint' do
        expect(HTTParty).to receive(:patch).with("#{described_class.base_url}#{described_class.endpoint}/#{id}", body: parameters, headers: authorization_header, format: :json).and_return(response)

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

        it 'returns the updated third party' do
          response = subject.save

          expect(response.record).to be_a(described_class)

          parameters.keys.each do |field|
            expect(response.record.send(field.to_sym)).to eq(parameters[field])
          end
          
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
    let(:trading_name) { 'foobar' }
    let(:identification) { '70.298.607/0001-85' }
    let(:address) { 'Rua Foo Bar' }
    let(:phone) { '551232323435' }
    let(:social_reason) { 'Foo Bar Eireli' }
    let(:municipal_inscription) { 'ISENTO' }
    let(:state_inscription) { 'ISENTO' }
    let(:email) { 'foo@bar.com' }
    let(:notes) { 'Obs' }
    let(:supplier) { true }
    let(:customer) { true }
    let(:retention) { true }
    let(:whatsapp) { '5512998779605' }
    let(:twitter) { 'https://twitter.com/foobar' }
    let(:facebook) { 'https://facebook.com/foobar' }
    let(:linkedin) { 'https://linkedi.com/foobar' }
    let(:google) { 'https://google.com/foobar' }
    let(:instagram) { 'https://instagram.com/foobar' }
    let(:site) { 'https://foobar.com' }
    let(:csll) { BigDecimal('0.15') }
    let(:pis) { BigDecimal('0.16') }
    let(:cofins) { BigDecimal('0.17') }
    let(:irpj) { BigDecimal('0.22') }
    let(:values_past) { BigDecimal('19999.99') }
    let(:parameters) do
      {
        trading_name: trading_name, identification: identification, address: address, phone: phone, social_reason: social_reason,
        municipal_inscription: municipal_inscription, state_inscription: state_inscription, email: email, notes: notes,
        supplier: supplier, customer: customer, retention: retention, whatsapp: whatsapp, twitter: twitter, facebook: facebook,
        linkedin: linkedin, google: google, instagram: instagram, site: site, csll: csll, pis: pis, cofins: cofins, irpj: irpj, values_past: values_past
      }
    end

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

      it 'issues a patch to the third party update endpoint' do
        expect(HTTParty).to receive(:patch).with("#{described_class.base_url}#{described_class.endpoint}/#{id}", body: parameters, headers: authorization_header, format: :json).and_return(response)

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

        it 'returns the updated third party' do
          response = subject.update

          expect(response.record).to be_a(described_class)

          parameters.keys.each do |field|
            expect(response.record.send(field.to_sym)).to eq(parameters[field])
          end
          
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

        it 'returns the third party with its errors' do
          response = subject.update

          expect(response.record).to be_a(described_class)
          expect(response.errors).to match_array(errors)
        end
      end
    end
  end

  describe '#destroy' do
    let(:trading_name) { 'foobar' }
    let(:parameters) { { trading_name: trading_name } }

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

      it 'issues a delete to the third party delete endpoint' do
        expect(HTTParty).to receive(:delete).with("#{described_class.base_url}#{described_class.endpoint}/#{id}", headers: authorization_header, format: :json).and_return(response)

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
end
