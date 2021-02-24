require 'httparty'
require 'forwardable'

module Nova
  module API
    class Base < Nova::API::Utils::BaseStruct
      extend Forwardable
      include HTTParty

      format :json

      SCHEME = 'https'
      HOST = 'nova.money'

      def self.base_url
        raise Nova::API::MissingSubdomainError, 'The subdomain must be informed' if configuration.subdomain.nil? || configuration.subdomain.empty?

        "#{SCHEME}://#{configuration.subdomain}.#{HOST}"
      end

      protected

      def self.initialize_empty_model_with_id(klass, id)
        klass.new(Hash[*klass.attribute_names.map{ |key| [key, nil] }.flatten].merge(id: id))
      end

      def self.do_get_search(endpoint, query, headers = {})
        set_base_uri

        response = self.get(endpoint, query: query, headers: headers.merge(authorization_header))

        Nova::API::ListResponse.build(response, self)
      end

      def do_delete(endpoint, headers = {})
        set_base_uri

        response = self.class.delete(endpoint, headers: headers.merge(authorization_header))

        Nova::API::Response.build(response)
      end

      def do_patch(endpoint, data, headers = {})
        set_base_uri

        if data.nil? || data.empty?
          response = self.class.patch(endpoint, headers: headers.merge(authorization_header))

          Nova::API::Response.build(response)
        else
          payload = data.dup
          payload.delete(:id)

          response = self.class.patch(endpoint, body: payload, headers: headers.merge(authorization_header))

          Nova::API::Response.build(response, self)
        end
      end

      def do_post(endpoint, data, headers = {})
        set_base_uri

        response = self.class.post(endpoint, body: data, headers: headers.merge(authorization_header))

        Nova::API::Response.build(response, self)
      end

      def protect_operation_from_missing_id
        raise Nova::API::MissingIdError, 'This operation requires an ID to be set' if id.nil?
      end

      private

      def self.authorization_header
        { HTTP_PERSISTENT_TOKEN: configuration.api_key }
      end
      def_delegator self, :authorization_header

      def self.configuration
        Nova::API.configuration
      end
      def_delegator self, :configuration

      def self.set_base_uri
        base_uri base_url
      end
      def_delegator self, :set_base_uri
    end
  end
end
