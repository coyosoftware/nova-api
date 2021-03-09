module Nova
  module API
    module Resource
      class Bill < Nova::API::Base
        class Apportionment < Nova::API::Utils::BaseStruct
          ALLOWED_ATTRIBUTES = [:value, :apportionment_value_ids]

          attribute :apportionment_value_ids, Dry::Types['strict.array'].of(Dry::Types['coercible.integer'].optional)
          attribute :value, Dry::Types['coercible.decimal']
        end

        ALLOWED_ATTRIBUTES = [
          :additional_information, :apportionments, :company_id, :date, :document_type, :document_number, :due_type, :financial_account_id,
          :first_due_date, :forecast, :installments, :installments_number, :third_party_id, :total_value
        ]

        attribute? :id, Dry::Types['coercible.integer'].optional
        attribute? :additional_information, Dry::Types['coercible.string'].optional
        attribute? :apportionments, Dry::Types['strict.array'].of(Nova::API::Resource::Bill::Apportionment).optional
        attribute :company_id, Dry::Types['coercible.integer']
        attribute :date, Dry::Types['coercible.string'].constrained(format: DATE_REGEX)
        attribute :document_type, Dry::Types['coercible.integer']
        attribute? :document_number, Dry::Types['coercible.string']
        attribute? :due_type, Dry::Types['coercible.integer']
        attribute :financial_account_id, Dry::Types['coercible.integer']
        attribute :first_due_date, Dry::Types['coercible.string'].constrained(format: DATE_REGEX)
        attribute :forecast, Dry::Types['strict.bool']
        attribute? :installments, Dry::Types['strict.array'].of(Nova::API::Resource::Installment).optional
        attribute :installments_number, Dry::Types['coercible.integer']
        attribute :third_party_id, Dry::Types['coercible.integer']
        attribute :total_value, Dry::Types['coercible.decimal']

        def self.endpoint
          '/api/bills'
        end
      end
    end
  end
end
