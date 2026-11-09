module Nova
  module API
    module Resource
      class Forecast < Nova::API::Base
        ALLOWED_ATTRIBUTES = [
          :additional_information, :apportionments, :close, :date, :document_type, :document_number, :due_date, :financial_accounts, :gross_value, :value
        ]

        attribute? :id, Dry::Types['coercible.integer'].optional
        attribute? :additional_information, Dry::Types['coercible.string'].optional
        attribute? :apportionments, Dry::Types['strict.array'].of(Nova::API::Resource::Bill::Apportionment).optional
        attribute :close, Dry::Types['strict.bool']
        attribute :date, Dry::Types['coercible.string'].constrained(format: DATE_REGEX)
        attribute :document_type, Dry::Types['coercible.integer']
        attribute? :document_number, Dry::Types['coercible.string']
        attribute :due_date, Dry::Types['coercible.string'].constrained(format: DATE_REGEX)
        attribute? :financial_accounts, Dry::Types['strict.array'].of(Nova::API::Resource::Bill::FinancialAccount).optional
        attribute? :gross_value, Dry::Types['coercible.float'].optional
        attribute :value, Dry::Types['coercible.float']

        def self.endpoint
          '/api/forecasts'
        end

        def self.confirm(id, parameters)
          model = new(parameters.merge(id:))

          model.confirm
        end

        def endpoint
          protect_operation_from_missing_value

          "/api/forecasts/#{id}"
        end

        def confirm
          protect_operation_from_missing_value

          do_post("#{self.class.endpoint}/#{id}/confirm", allowed_attributes)
        end
      end
    end
  end
end
