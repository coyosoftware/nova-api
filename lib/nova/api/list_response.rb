require 'httparty'
require 'dry-struct'
require 'dry-types'

module Nova
  module API
    class ListResponse < Dry::Struct
      attribute :records, Dry::Types['strict.array'].of(Dry::Types['nominal.any']).optional
      attribute :errors, Dry::Types['strict.array'].of(Dry::Types['coercible.string'])
      attribute :success, Dry::Types['strict.bool']

      def self.build(response, klass)
        success = response.success?

        parsed_response = response.parsed_response

        errors = []
        records = nil

        if parsed_response.is_a?(Array)
          records = klass.nil? ? nil : parsed_response.map { |object| klass.new(object) }
        else
          parsed_response = parsed_response.to_h

          errors =
            if parsed_response.has_key?('error')
              parsed_response['error'].is_a?(Array) ? parsed_response['error'] : [parsed_response['error']]
            elsif parsed_response.has_key?('errors')
              parsed_response['errors'].is_a?(Array) ? parsed_response['errors'] : [parsed_response['errors']]
            end
        end

        new(success: success, errors: errors, records: records)
      end
    end
  end
end
