require 'dry-struct'
require 'dry-types'

module Nova
  module API
    module Utils
      class BaseStruct < Dry::Struct
        DATE_REGEX = /\A\d{4}-\d{2}-\d{2}\z/

        transform_keys(&:to_sym)

        def allowed_attributes
          return attributes unless self.class.const_defined?('ALLOWED_ATTRIBUTES')

          data = {}

          self.class.const_get('ALLOWED_ATTRIBUTES').each do |key|
            next unless attributes.keys.include? key

            value = attributes[key]

            if value.is_a? Array
              data[key.to_sym] = value.map { |attribute| permit_value(key, attribute) }
            else
              data[key.to_sym] = permit_value(key, value)
            end
          end

          data
        end

        private

        def permit_value(key, value)
          value.respond_to?(:allowed_attributes) ?  value.allowed_attributes : value
        end
      end
    end
  end
end
