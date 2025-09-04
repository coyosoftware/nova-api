require 'httparty'
require 'forwardable'

module Nova
  module API
    class Base < Nova::API::Utils::BaseStruct
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
      def_delegator self, :base_url

      def endpoint
        raise EndpointNotConfiguredError, 'Each class must implement its own endpoint'
      end

      protected

      def self.do_get_search(endpoint, query, object = self)
        response = perform_get(endpoint, query)

        Nova::API::ListResponse.build(response, object)
      end

      def self.do_get(endpoint, query, object = self)
        response = perform_get(endpoint, query)

        Nova::API::Response.build(response, object)
      end
      def_delegator self, :do_get

      def do_delete(endpoint)
        Kernel.p "[NOVA-API] Issuing DELETE to #{base_url}#{endpoint}, headers: #{authorization_header}" if configuration.debug?

        response = HTTParty.delete("#{base_url}#{endpoint}", headers: authorization_header, format: :json)

        Nova::API::Response.build(response)
      end

      def do_patch(endpoint, data)
        Kernel.p "[NOVA-API] Issuing PATCH to #{base_url}#{endpoint}, headers: #{authorization_header}" if configuration.debug?

        if data.nil? || data.empty?
          response = HTTParty.patch("#{base_url}#{endpoint}", headers: authorization_header, format: :json)

          Nova::API::Response.build(response)
        else
          payload = data.dup
          payload.delete(:id)

          response = HTTParty.patch("#{base_url}#{endpoint}", body: payload, headers: authorization_header, format: :json)

          Nova::API::Response.build(response, self)
        end
      end

      def do_post(endpoint, data, object = self)
        Kernel.p "[NOVA-API] Issuing POST to #{base_url}#{endpoint}, headers: #{authorization_header}" if configuration.debug?

        response = HTTParty.post("#{base_url}#{endpoint}", body: data, headers: authorization_header, format: :json)

        Nova::API::Response.build(response, object)
      end

      def protect_operation_from_missing_value(attribute = :id)
        raise Nova::API::MissingIdError, 'This operation requires an ID to be set' if send(attribute).nil?
      end

      private

      def self.perform_get(endpoint, query, headers = {})
        Kernel.p "[NOVA-API] Issuing GET to #{base_url}#{endpoint}, headers: #{headers.merge(authorization_header)}" if configuration.debug?

        if query
          HTTParty.get("#{base_url}#{endpoint}", query: query, headers: headers.merge(authorization_header), format: :json)
        else
          HTTParty.get("#{base_url}#{endpoint}", headers: headers.merge(authorization_header), format: :json)
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
    end
  end
end
