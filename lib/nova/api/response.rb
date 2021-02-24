require 'httparty'
require 'dry-struct'
require 'dry-types'

module Nova
  module API
    class Response < Nova::API::Utils::BaseStruct
      attribute? :record, Dry::Types['nominal.any']
      attribute :errors, Dry::Types['strict.array'].of(Dry::Types['coercible.string']) 
      attribute :success, Dry::Types['strict.bool']

      def self.build(response, object = nil)
        success = response.success?

        parsed_response = response.parsed_response.to_h

        record = nil

        errors = extract_error_from_response('error', parsed_response)
        errors ||= extract_error_from_response('errors', parsed_response)
        errors ||= []

        if object
          record = object.id.nil? ? object.class.new(object.attributes.merge(id: parsed_response['id'])) : object
        end

        new(success: success, errors: errors, record: record)
      end

      private

      def self.extract_error_from_response(field, response)
        return unless response.has_key?(field)

        response[field].is_a?(Array) ? response[field] : [response[field]]
      end
    end
  end
end
