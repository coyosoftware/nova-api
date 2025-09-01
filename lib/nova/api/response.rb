require 'httparty'
require 'dry-struct'
require 'dry-types'

module Nova
  module API
    class Response < Nova::API::Utils::BaseStruct
      attribute? :record, Dry::Types['nominal.any']
      attribute :errors, Dry::Types['strict.array'].of(Dry::Types['coercible.string'])
      attribute :success, Dry::Types['strict.bool']
      attribute :status, Dry::Types['coercible.integer']

      def self.build(response, object = nil)
        success = response.success?
        status = response.code

        parsed_response = response.parsed_response.to_h

        record = nil

        errors = extract_error_from_response('error', parsed_response)
        errors ||= extract_error_from_response('errors', parsed_response)
        errors ||= []

        record = object.class.new(object.attributes.merge(parsed_response)) if object

        new(success: success, errors: errors, record: record, status: status)
      end

      private

      def self.extract_error_from_response(field, response)
        return unless response.has_key?(field)

        response[field].is_a?(Array) ? response[field] : [response[field]]
      end
    end
  end
end
