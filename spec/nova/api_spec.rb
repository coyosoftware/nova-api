RSpec.describe Nova::API do
  it "has a version number" do
    expect(Nova::API::VERSION).not_to be_nil
  end

  describe '.configure' do
    it 'allows the configuration of the api key' do
      expect { described_class.configure { |config| config.api_key = 'foo-bar-baz' } }.to change(described_class.configuration, :api_key).to 'foo-bar-baz'
    end

    it 'allows the configuration of the subdomain' do
      expect { described_class.configure { |config| config.subdomain = 'foobarbaz' } }.to change(described_class.configuration, :subdomain).to 'foobarbaz'
    end

    context 'when called outside the main thread' do
      before do
        described_class.configure do |config|
          config.subdomain = 'boot'
          config.api_key = 'boot-key'
        end
      end

      it 'does not change the configuration shared by the process' do
        Thread.new { described_class.configure { |config| config.subdomain = 'tenant' } }.join

        expect(described_class.configuration.subdomain).to eq('boot')
      end

      it 'keeps the boot values of the attributes it does not set' do
        api_key = Thread.new do
          described_class.configure { |config| config.subdomain = 'tenant' }
          described_class.configuration.api_key
        end.value

        expect(api_key).to eq('boot-key')
      end

      it 'accumulates successive calls on the same thread' do
        values = Thread.new do
          described_class.configure { |config| config.subdomain = 'tenant' }
          described_class.configure { |config| config.api_key = 'tenant-key' }
          [described_class.configuration.subdomain, described_class.configuration.api_key]
        end.value

        expect(values).to eq(%w[tenant tenant-key])
      end

      it 'isolates concurrent threads from each other' do
        mismatches = Array.new(8) do |index|
          Thread.new do
            500.times.count do
              described_class.configure { |config| config.subdomain = "tenant#{index}" }
              Thread.pass
              !Nova::API::Base.base_url.start_with?("https://tenant#{index}.")
            end
          end
        end.sum(&:value)

        expect(mismatches).to eq(0)
      end
    end
  end

  describe '.configuration' do
    it 'exposes what was configured on the main thread to the other threads' do
      described_class.configure { |config| config.subdomain = 'boot' }

      expect(Thread.new { described_class.configuration.subdomain }.value).to eq('boot')
    end
  end

  describe '.with_configuration' do
    before { described_class.configure { |config| config.subdomain = 'boot' } }

    it 'applies the overrides inside the block' do
      described_class.with_configuration(subdomain: 'tenant') do
        expect(described_class.configuration.subdomain).to eq('tenant')
      end
    end

    it 'returns the value of the block' do
      expect(described_class.with_configuration(subdomain: 'tenant') { :result }).to eq(:result)
    end

    it 'restores the previous configuration after the block' do
      described_class.with_configuration(subdomain: 'tenant') {}

      expect(described_class.configuration.subdomain).to eq('boot')
    end

    it 'restores the previous configuration when the block raises' do
      expect { described_class.with_configuration(subdomain: 'tenant') { raise 'boom' } }.to raise_error('boom')

      expect(described_class.configuration.subdomain).to eq('boot')
    end

    it 'restores the outer scope when nested' do
      described_class.with_configuration(subdomain: 'outer') do
        described_class.with_configuration(subdomain: 'inner') {}

        expect(described_class.configuration.subdomain).to eq('outer')
      end
    end

    it 'does not leak to the next job of a pooled thread' do
      subdomain = Thread.new do
        described_class.with_configuration(subdomain: 'tenant') {}
        described_class.configuration.subdomain
      end.value

      expect(subdomain).to eq('boot')
    end

    it 'does not affect other threads' do
      described_class.with_configuration(subdomain: 'tenant') do
        expect(Thread.new { described_class.configuration.subdomain }.value).to eq('boot')
      end
    end

    it 'scopes configure calls made inside the block' do
      described_class.with_configuration(subdomain: 'tenant') do
        described_class.configure { |config| config.subdomain = 'changed' }
      end

      expect(described_class.configuration.subdomain).to eq('boot')
    end

    it 'raises for an unknown attribute' do
      expect { described_class.with_configuration(unknown: 'value') {} }.to raise_error(NoMethodError)
    end
  end

  describe "#apportionments" do
    it 'returns the Nova::API::Resource::Apportionment class' do
      expect(Nova::API::Client.new.apportionments).to eq(Nova::API::Resource::Apportionment)
    end
  end

  describe "#apportionment_values" do
    it 'returns the Nova::API::Resource::ApportionmentValue class' do
      expect(Nova::API::Client.new.apportionment_values).to eq(Nova::API::Resource::ApportionmentValue)
    end
  end

  describe "#banks" do
    it 'returns the Nova::API::Resource::Bank class' do
      expect(Nova::API::Client.new.banks).to eq(Nova::API::Resource::Bank)
    end
  end

  describe "#cards" do
    it 'returns the Nova::API::Resource::Card class' do
      expect(Nova::API::Client.new.cards).to eq(Nova::API::Resource::Card)
    end
  end

  describe "#cashes" do
    it 'returns the Nova::API::Resource::Cash class' do
      expect(Nova::API::Client.new.cashes).to eq(Nova::API::Resource::Cash)
    end
  end

  describe "#companies" do
    it 'returns the Nova::API::Resource::Company class' do
      expect(Nova::API::Client.new.companies).to eq(Nova::API::Resource::Company)
    end
  end

  describe "#current_assets" do
    it 'returns the Nova::API::Resource::CurrentAsset class' do
      expect(Nova::API::Client.new.current_assets).to eq(Nova::API::Resource::CurrentAsset)
    end
  end


  describe "#direct_payables" do
    it 'returns the Nova::API::Resource::DirectPayable class' do
      expect(Nova::API::Client.new.direct_payables).to eq(Nova::API::Resource::DirectPayable)
    end
  end

  describe "#direct_receivables" do
    it 'returns the Nova::API::Resource::DirectReceivable class' do
      expect(Nova::API::Client.new.direct_receivables).to eq(Nova::API::Resource::DirectReceivable)
    end
  end

  describe "#financial_accounts" do
    it 'returns the Nova::API::Resource::FinancialAccount class' do
      expect(Nova::API::Client.new.financial_accounts).to eq(Nova::API::Resource::FinancialAccount)
    end
  end

  describe "#installments" do
    it 'returns the Nova::API::Resource::Installment class' do
      expect(Nova::API::Client.new.installments).to eq(Nova::API::Resource::Installment)
    end
  end

  describe "#payables" do
    it 'returns the Nova::API::Resource::Payable class' do
      expect(Nova::API::Client.new.payables).to eq(Nova::API::Resource::Payable)
    end
  end

  describe "#permissions" do
    it 'returns the Nova::API::Resource::Permission class' do
      expect(Nova::API::Client.new.permissions).to eq(Nova::API::Resource::Permission)
    end
  end

  describe "#receivables" do
    it 'returns the Nova::API::Resource::Receivable class' do
      expect(Nova::API::Client.new.receivables).to eq(Nova::API::Resource::Receivable)
    end
  end

  describe "#third_parties" do
    it 'returns the Nova::API::Resource::ThirdParty class' do
      expect(Nova::API::Client.new.third_parties).to eq(Nova::API::Resource::ThirdParty)
    end
  end

  describe "#webhooks" do
    it 'returns the Nova::API::Resource::Webhook class' do
      expect(Nova::API::Client.new.webhooks).to eq(Nova::API::Resource::Webhook)
    end
  end
end
