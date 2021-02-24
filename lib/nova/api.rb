require "nova/configuration"

require "nova/api/utils/base_struct"
require "nova/api/version"
require "nova/api/base"
require "nova/api/list_response"
require "nova/api/response"

require "nova/api/resource/apportionment"

require "nova/api/search_params/apportionment"

module Nova
  module API
    class Error < StandardError; end
    class MissingSubdomainError < Error; end
    class MissingIdError < Error; end

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
    end
  end
end
