require 'httparty'
require 'forwardable'

module Nova
  module API
    class Base < Nova::API::Utils::BaseStruct
      include HTTParty

      format :json

      SCHEME = 'https'
      PRODUCTION_HOST = 'nova.money'
      STAGING_HOST = 'staging.nova.money'

      def self.endpoint
        raise EndpointNotConfiguredError, 'Each class must implement its own endpoint'
      end

      def self.base_url
        raise Nova::API::MissingSubdomainError, 'The subdomain must be informed' if configuration.subdomain.nil? || configuration.subdomain.empty?

        host = configuration.use_staging? ? STAGING_HOST : PRODUCTION_HOST

        "#{SCHEME}://#{configuration.subdomain}.#{host}"
      end

      def endpoint
        raise EndpointNotConfiguredError, 'Each class must implement its own endpoint'
      end

      protected

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

        Kernel.p "[NOVA-API] Issuing DELETE to #{self.class.base_uri}#{endpoint}, headers: #{authorization_header}" if configuration.debug?

        response = self.class.delete(endpoint, headers: authorization_header)

        Nova::API::Response.build(response)
      end

      def do_patch(endpoint, data)
        set_base_uri

        Kernel.p "[NOVA-API] Issuing PATCH to #{self.class.base_uri}#{endpoint}, headers: #{authorization_header}" if configuration.debug?

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

        Kernel.p "[NOVA-API] Issuing POST to #{self.class.base_uri}#{endpoint}, headers: #{authorization_header}" if configuration.debug?

        response = self.class.post(endpoint, body: data, headers: authorization_header)

        Nova::API::Response.build(response, self)
      end

      def protect_operation_from_missing_value(attribute = :id)
        raise Nova::API::MissingIdError, 'This operation requires an ID to be set' if send(attribute).nil?
      end

      private

      def self.perform_get(endpoint, query, headers = {})
        set_base_uri

        Kernel.p "[NOVA-API] Issuing GET to #{base_uri}#{endpoint}, headers: #{headers.merge(authorization_header)}" if configuration.debug?

        response =
          if query
            self.get(endpoint, query: query, headers: headers.merge(authorization_header))
          else
            self.get(endpoint, headers: headers.merge(authorization_header))
          end
      end

      def self.authorization_header
        { 'Persistent-Token': configuration.api_key }.dup
      end
      def_delegator self, :authorization_header

      def self.configuration
        Nova::API.configuration
      end
      def_delegator self, :configuration

      def self.set_base_uri
        if configuration.debug?
          debug_output $stdout

          Kernel.p "[NOVA-API] Changing base URI from #{base_uri} to #{base_url}"
        end

        default_options[:base_uri] = base_url
      end
      def_delegator self, :set_base_uri
    end
  end
end
