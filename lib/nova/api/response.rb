require 'httparty'
require 'dry-struct'
require 'dry-types'

module Nova
  module API
    class Response < Dry::Struct
      attribute? :record, Dry::Types['nominal.any']
      attribute :errors, Dry::Types['strict.array'].of(Dry::Types['coercible.string']) 
      attribute :success, Dry::Types['strict.bool']

      def self.build(response, object = nil)
        success = response.success?

        parsed_response = response.parsed_response.to_h

        errors =
          if parsed_response.has_key?('error')
            parsed_response['error'].is_a?(Array) ? parsed_response['error'] : [parsed_response['error']]
          elsif parsed_response.has_key?('errors')
            parsed_response['errors'].is_a?(Array) ? parsed_response['errors'] : [parsed_response['errors']]
          else
            []
          end

        record =
          if object
            object.id.nil? ? object.class.new(object.attributes.merge(id: parsed_response['id'])) : object
          else
            nil
          end

        new(success: success, errors: errors, record: record)
      end
    end
  end
end
