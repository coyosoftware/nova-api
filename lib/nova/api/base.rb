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

      def self.endpoint
        raise EndpointNotConfiguredError, 'Each class must implement its own endpoint'
      end

      def self.base_url
        raise Nova::API::MissingSubdomainError, 'The subdomain must be informed' if configuration.subdomain.nil? || configuration.subdomain.empty?

        "#{SCHEME}://#{configuration.subdomain}.#{HOST}"
      end

      def endpoint
        raise EndpointNotConfiguredError, 'Each class must implement its own endpoint'
      end

      protected

      def allowed_attributes
        return attributes unless self.class.const_defined?('ALLOWED_ATTRIBUTES')

        data = attributes.dup

        data.keys.each { |key| data.delete(key.to_sym) unless self.class.const_get('ALLOWED_ATTRIBUTES').include?(key.to_sym) }

        data
      end

      def self.initialize_empty_model_with_id(klass, id, additional_attributes = {})
        data = klass.attribute_names.map { |key| additional_attributes[key] ? [key, additional_attributes[key]] : [key, nil] }

        klass.new(Hash[*data.flatten].merge(id: id))
      end

      def self.do_get_search(endpoint, query, object = self)
        response = perform_get(endpoint, query, headers)

        Nova::API::ListResponse.build(response, object)
      end

      def self.do_get(endpoint, query, object = self)
        response = perform_get(endpoint, query, headers)

        Nova::API::Response.build(response, object)
      end
      def_delegator self, :do_get

      def do_delete(endpoint)
        set_base_uri

        response = self.class.delete(endpoint, headers: authorization_header)

        Nova::API::Response.build(response)
      end

      def do_patch(endpoint, data)
        set_base_uri

        if data.nil? || data.empty?
          response = self.class.patch(endpoint, headers: authorization_header)

          Nova::API::Response.build(response)
        else
          payload = data.dup
          payload.delete(:id)

          response = self.class.patch(endpoint, body: payload, headers: authorization_header)

          Nova::API::Response.build(response, self)
        end
      end

      def do_post(endpoint, data)
        set_base_uri

        response = self.class.post(endpoint, body: data, headers: authorization_header)

        Nova::API::Response.build(response, self)
      end

      def protect_operation_from_missing_value(attribute = :id)
        raise Nova::API::MissingIdError, 'This operation requires an ID to be set' if send(attribute).nil?
      end

      private

      def self.perform_get(endpoint, query, headers = {})
        set_base_uri

        response =
          if query
            self.get(endpoint, query: query, headers: headers.merge(authorization_header))
          else
            self.get(endpoint, headers: headers.merge(authorization_header))
          end
      end

      def self.authorization_header
        { 'Persistent-Token': configuration.api_key }
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
