require 'dry-struct'
require 'dry-types'

module Nova
  module API
    module Utils
      class BaseStruct < Dry::Struct
        extend Forwardable

        DATE_REGEX = /\A\d{4}-\d{2}-\d{2}\z/

        transform_keys(&:to_sym)

        def allowed_attributes
          return attributes unless self.class.const_defined?('ALLOWED_ATTRIBUTES')

          data = {}

          self.class.const_get('ALLOWED_ATTRIBUTES').each do |key|
            next unless attributes.keys.include? key

            value = attributes[key]

            data[key.to_sym] = extract_value(key, value)
          end

          data
        end

        protected

        def self.initialize_empty_model_with_id(klass, id, additional_attributes = {})
          data = klass.schema.type.keys.map do |field|
            name = field.name

            value_for_field(name, additional_attributes[name], field)
          end

          klass.new(Hash[*data.flatten].merge(id: id))
        end

        private

        def extract_value(key, value)
          value.is_a?(Array) ? value.map { |attribute| permit_value(key, attribute) } : permit_value(key, value)
        end

        def permit_value(key, value)
          value.respond_to?(:allowed_attributes) ?  value.allowed_attributes : value
        end

        def self.value_for_field(name, override_value, field)
          return [name, override_value] if override_value

          type = field.type

          type.optional? ? [name, nil] :  [name, generate_valid_value_for(type)]
        end

        def self.generate_valid_value_for(type)
          case type.name
          when Dry::Types['integer'].name, Dry::Types['float'].name, Dry::Types['decimal'].name
            0
          when Dry::Types['bool'].name
            false
          else
            nil
          end
        end
        def_delegator self, :generate_valid_value_for
      end
    end
  end
end
