RSpec.describe Nova::API::Resource::Card do
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

    it { is_expected.to have_attribute(:description, Dry::Types['coercible.string'].optional) }
    it { is_expected.to have_attribute(:institution, Dry::Types['coercible.string'].optional) }

    it { is_expected.to have_attribute(:taxes, Dry::Types['strict.array'].of(Nova::API::Resource::Card::Tax)) }

    context 'taxes' do
      subject { described_class::Tax }

      it { is_expected.to have_attribute(:percentage, Dry::Types['coercible.float']) }
      it { is_expected.to have_attribute(:fixed, Dry::Types['coercible.float']) }
      it { is_expected.to have_attribute(:type, Dry::Types['coercible.integer']) }
      it { is_expected.to have_attribute(:id, Dry::Types['coercible.integer']) }
      it { is_expected.to have_attribute(:installments, Dry::Types['coercible.integer']) }
      it { is_expected.to have_attribute(:days, Dry::Types['coercible.integer']) }
    end
  end

  describe '.endpoint' do
    it 'returns the card endpoint' do
      expect(described_class.endpoint).to eq('/api/cards')
    end
  end

  describe '.list' do
    let(:company_id) { 99 }
    let(:with_inactive) { true }
    let(:parameters) { { company_id: company_id, with_inactive: with_inactive } }
    let(:data) do
      [
        {
          id: 18, company: { id: 6, name: 'Moniz, Velasques e Solimões' }, active: true, description: 'Antunes Comércio',
          image: 'https://assets.nova.money/images/card_logos/mercadopago.png', balance: 0, institution: 'Mercado Pago',
          taxes: [
            { id: 1, percentage: BigDecimal('1.33'), fixed: BigDecimal('0.55'), type: Nova::API::Resource::Card::Tax::TYPE::DEBIT, installments: 1, days: 1 },
            { id: 2, percentage: BigDecimal('1.33'), fixed: BigDecimal('0.55'), type: Nova::API::Resource::Card::Tax::TYPE::CREDIT, installments: 1, days: 1 },
            { id: 3, percentage: BigDecimal('1.33'), fixed: BigDecimal('0.55'), type: Nova::API::Resource::Card::Tax::TYPE::CREDIT_WITH_INSTALLMENTS, installments: 2, days: 1 },
            { id: 4, percentage: BigDecimal('1.33'), fixed: BigDecimal('0.55'), type: Nova::API::Resource::Card::Tax::TYPE::CREDIT_WITH_INSTALLMENTS, installments: 3, days: 1 },
            { id: 5, percentage: BigDecimal('1.33'), fixed: BigDecimal('0.55'), type: Nova::API::Resource::Card::Tax::TYPE::BANK_SLIP, installments: 1, days: 1 },
            { id: 6, percentage: BigDecimal('1.33'), fixed: BigDecimal('0.55'), type: Nova::API::Resource::Card::Tax::TYPE::PIX, installments: 1, days: 1 }
          ]
        },
        {
          id: 22, company: { id: 6, name: 'Moniz, Velasques e Solimões' }, active: true, description: 'Castanho-Custódio',
          image: 'https://assets.nova.money/images/card_logos/izettle.png', balance: 0, institution: 'iZettle',
          taxes: [
            { id: 7, percentage: BigDecimal('1.33'), fixed: BigDecimal('0.55'), type: Nova::API::Resource::Card::Tax::TYPE::DEBIT, installments: 1, days: 1 },
            { id: 8, percentage: BigDecimal('1.33'), fixed: BigDecimal('0.55'), type: Nova::API::Resource::Card::Tax::TYPE::CREDIT, installments: 1, days: 1 },
            { id: 9, percentage: BigDecimal('1.33'), fixed: BigDecimal('0.55'), type: Nova::API::Resource::Card::Tax::TYPE::BANK_SLIP, installments: 1, days: 1 },
            { id: 10, percentage: BigDecimal('1.33'), fixed: BigDecimal('0.55'), type: Nova::API::Resource::Card::Tax::TYPE::PIX, installments: 1, days: 1 }
          ]
        }
      ]
    end
    let(:response) { double(:response, success?: true, parsed_response: data, code: 200) }

    subject { described_class.list(Nova::API::SearchParams::CurrentAsset.new parameters) }

    it 'issues a get to the card list endpoint' do
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

        expect(response.records).to all(be_a(Nova::API::Resource::Card))
        
        expect(response.records[0].id).to eq(data[0][:id])
        expect(response.records[0].company.id).to eq(data[0][:company][:id])
        expect(response.records[0].company.name).to eq(data[0][:company][:name])
        expect(response.records[0].active).to eq(data[0][:active])
        expect(response.records[0].image).to eq(data[0][:image])
        expect(response.records[0].balance).to eq(data[0][:balance])
        expect(response.records[0].description).to eq(data[0][:description])
        expect(response.records[0].institution).to eq(data[0][:institution])

        expect(response.records[0].taxes[0].percentage).to eq(data[0][:taxes][0][:percentage])
        expect(response.records[0].taxes[0].fixed).to eq(data[0][:taxes][0][:fixed])
        expect(response.records[0].taxes[0].type).to eq(data[0][:taxes][0][:type])
        expect(response.records[0].taxes[0].installments).to eq(data[0][:taxes][0][:installments])
        expect(response.records[0].taxes[0].days).to eq(data[0][:taxes][0][:days])

        expect(response.records[0].taxes[1].percentage).to eq(data[0][:taxes][1][:percentage])
        expect(response.records[0].taxes[1].fixed).to eq(data[0][:taxes][1][:fixed])
        expect(response.records[0].taxes[1].type).to eq(data[0][:taxes][1][:type])
        expect(response.records[0].taxes[1].installments).to eq(data[0][:taxes][1][:installments])
        expect(response.records[0].taxes[1].days).to eq(data[0][:taxes][1][:days])

        expect(response.records[0].taxes[2].percentage).to eq(data[0][:taxes][2][:percentage])
        expect(response.records[0].taxes[2].fixed).to eq(data[0][:taxes][2][:fixed])
        expect(response.records[0].taxes[2].type).to eq(data[0][:taxes][2][:type])
        expect(response.records[0].taxes[2].installments).to eq(data[0][:taxes][2][:installments])
        expect(response.records[0].taxes[2].days).to eq(data[0][:taxes][2][:days])

        expect(response.records[0].taxes[3].percentage).to eq(data[0][:taxes][3][:percentage])
        expect(response.records[0].taxes[3].fixed).to eq(data[0][:taxes][3][:fixed])
        expect(response.records[0].taxes[3].type).to eq(data[0][:taxes][3][:type])
        expect(response.records[0].taxes[3].installments).to eq(data[0][:taxes][3][:installments])
        expect(response.records[0].taxes[3].days).to eq(data[0][:taxes][3][:days])

        expect(response.records[1].id).to eq(data[1][:id])
        expect(response.records[1].company.id).to eq(data[1][:company][:id])
        expect(response.records[1].company.name).to eq(data[1][:company][:name])
        expect(response.records[1].active).to eq(data[1][:active])
        expect(response.records[1].image).to eq(data[1][:image])
        expect(response.records[1].balance).to eq(data[1][:balance])
        expect(response.records[1].description).to eq(data[1][:description])
        expect(response.records[1].institution).to eq(data[1][:institution])

        expect(response.records[1].taxes[0].percentage).to eq(data[1][:taxes][0][:percentage])
        expect(response.records[1].taxes[0].fixed).to eq(data[1][:taxes][0][:fixed])
        expect(response.records[1].taxes[0].type).to eq(data[1][:taxes][0][:type])
        expect(response.records[1].taxes[0].installments).to eq(data[1][:taxes][0][:installments])
        expect(response.records[1].taxes[0].days).to eq(data[1][:taxes][0][:days])

        expect(response.records[1].taxes[1].percentage).to eq(data[1][:taxes][1][:percentage])
        expect(response.records[1].taxes[1].fixed).to eq(data[1][:taxes][1][:fixed])
        expect(response.records[1].taxes[1].type).to eq(data[1][:taxes][1][:type])
        expect(response.records[1].taxes[1].installments).to eq(data[1][:taxes][1][:installments])
        expect(response.records[1].taxes[1].days).to eq(data[1][:taxes][1][:days])
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

  context 'card tax' do
    describe 'types' do
      subject { described_class::Tax::TYPE }

      it 'has the debig mapped as 0' do
        expect(subject::DEBIT).to eq(0)
      end

      it 'has the credit mapped as 1' do
        expect(subject::CREDIT).to eq(1)
      end

      it 'has the credit with installments mapped as 2' do
        expect(subject::CREDIT_WITH_INSTALLMENTS).to eq(2)
      end

      it 'has the bank slip mapped as 3' do
        expect(subject::BANK_SLIP).to eq(3)
      end

      it 'has the pix mapped as 4' do
        expect(subject::PIX).to eq(4)
      end
    end

    context 'methods' do
      describe '#debit?' do
        context 'when the type is debit' do
          subject { described_class::Tax.new(id: 1, percentage: 0, fixed: 0, type: described_class::Tax::TYPE::DEBIT, installments: 1, days: 1).debit? }

          it { is_expected.to be_truthy }
        end

        [described_class::Tax::TYPE::CREDIT, described_class::Tax::TYPE::CREDIT_WITH_INSTALLMENTS, described_class::Tax::TYPE::BANK_SLIP, described_class::Tax::TYPE::PIX].each do |type|
          context "when the type is #{type}" do
            subject { described_class::Tax.new(id: 1, percentage: 0, fixed: 0, type: type, installments: 1, days: 1).debit? }

            it { is_expected.to be_falsy }
          end
        end
      end

      describe '#credit?' do
        [described_class::Tax::TYPE::CREDIT, described_class::Tax::TYPE::CREDIT_WITH_INSTALLMENTS].each do |type|
          context "when the type is #{type}" do
            subject { described_class::Tax.new(id: 1, percentage: 0, fixed: 0, type: type, installments: 1, days: 1).credit? }

            it { is_expected.to be_truthy }
          end
        end

        [described_class::Tax::TYPE::DEBIT, described_class::Tax::TYPE::BANK_SLIP, described_class::Tax::TYPE::PIX].each do |type|
          context "when the type is #{type}" do
            subject { described_class::Tax.new(id: 1, percentage: 0, fixed: 0, type: type, installments: 1, days: 1).credit? }

            it { is_expected.to be_falsy }
          end
        end
      end

      describe '#bank_slip?' do
        context 'when the type is bank_slip' do
          subject { described_class::Tax.new(id: 1, percentage: 0, fixed: 0, type: described_class::Tax::TYPE::BANK_SLIP, installments: 1, days: 1).bank_slip? }

          it { is_expected.to be_truthy }
        end

        [described_class::Tax::TYPE::DEBIT, described_class::Tax::TYPE::CREDIT, described_class::Tax::TYPE::CREDIT_WITH_INSTALLMENTS, described_class::Tax::TYPE::PIX].each do |type|
          context "when the type is #{type}" do
            subject { described_class::Tax.new(id: 1, percentage: 0, fixed: 0, type: type, installments: 1, days: 1).bank_slip? }

            it { is_expected.to be_falsy }
          end
        end
      end

      describe '#pix?' do
        context 'when the type is pix' do
          subject { described_class::Tax.new(id: 1, percentage: 0, fixed: 0, type: described_class::Tax::TYPE::PIX, installments: 1, days: 1).pix? }

          it { is_expected.to be_truthy }
        end

        [described_class::Tax::TYPE::DEBIT, described_class::Tax::TYPE::CREDIT, described_class::Tax::TYPE::CREDIT_WITH_INSTALLMENTS, described_class::Tax::TYPE::BANK_SLIP].each do |type|
          context "when the type is #{type}" do
            subject { described_class::Tax.new(id: 1, percentage: 0, fixed: 0, type: type, installments: 1, days: 1).pix? }

            it { is_expected.to be_falsy }
          end
        end
      end
    end
  end
end
