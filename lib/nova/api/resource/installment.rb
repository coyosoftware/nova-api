module Nova
  module API
    module Resource
      class Installment < Nova::API::Base
        ALLOWED_ATTRIBUTES = %i[due_date gross_value number value]

        attribute? :id, Dry::Types['coercible.integer'].optional
        attribute :due_date, Dry::Types['coercible.string'].constrained(format: DATE_REGEX)
        attribute? :gross_value, Dry::Types['coercible.decimal'].optional
        attribute :number, Dry::Types['coercible.integer']
        attribute :value, Dry::Types['coercible.decimal']

        def self.endpoint
          '/api/installments'
        end
      end
    end
  end
end
