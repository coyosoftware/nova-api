require "nova/configuration"

require "nova/api/utils/base_struct"
require "nova/api/version"
require "nova/api/base"
require "nova/api/list_response"
require "nova/api/response"

require "nova/api/resource/apportionment_value"
require "nova/api/resource/apportionment"
require "nova/api/resource/financial_account"
require "nova/api/resource/third_party"

require "nova/api/search_params/apportionment"
require "nova/api/search_params/third_party"

module Nova
  module API
    class Error < StandardError; end
    class MissingSubdomainError < Error; end
    class MissingIdError < Error; end
    class EndpointNotConfiguredError < Error; end

    class << self
      def configuration
        @configuration ||= Configuration.new
      end

      def configure
        yield(configuration)
      end
    end

    class Client
      def apportionments
        Nova::API::Resource::Apportionment
      end

      def apportionment_values
        Nova::API::Resource::ApportionmentValue
      end

      def financial_accounts
        Nova::API::Resource::FinancialAccount
      end

      def third_parties
        Nova::API::Resource::ThirdParty
      end
    end
  end
end
