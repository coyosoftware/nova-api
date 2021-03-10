require 'httparty'
require 'dry-struct'
require 'dry-types'

module Nova
  module API
    class ListResponse < Nova::API::Utils::BaseStruct
      attribute :records, Dry::Types['strict.array'].of(Dry::Types['nominal.any']).optional
      attribute :errors, Dry::Types['strict.array'].of(Dry::Types['coercible.string'])
      attribute :success, Dry::Types['strict.bool']

      def self.build(response, klass)
        success = response.success?

        parsed_response = response.parsed_response

        records = nil

        if parsed_response.is_a?(Array)
          records = build_records(klass, parsed_response)
        else
          parsed_response = parsed_response.to_h

          errors = extract_error_from_response('error', parsed_response)
          errors ||= extract_error_from_response('errors', parsed_response)
        end

        errors ||= []

        new(success: success, errors: errors, records: records)
      end

      private

      def self.extract_error_from_response(field, response)
        return unless response.has_key?(field)

        response[field].is_a?(Array) ? response[field] : [response[field]]
      end

      def self.build_records(klass, response)
        response.map { |object| klass.new(object) } unless klass.nil?
      end
    end
  end
end
