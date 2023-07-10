module Nova
  module API
    module Resource
      class DirectBill < Nova::API::Base
        class Installment < Nova::API::Utils::BaseStruct
          ALLOWED_ATTRIBUTES = %i[current_asset_id document_number document_type due_date value]

          attribute :current_asset_id, Dry::Types['coercible.integer']
          attribute? :document_number, Dry::Types['coercible.string']
          attribute :document_type, Dry::Types['coercible.integer']
          attribute :due_date, Dry::Types['coercible.string'].constrained(format: DATE_REGEX)
          attribute :value, Dry::Types['coercible.float']
        end

        ALLOWED_ATTRIBUTES = [
          :addition, :additional_information, :apportionments, :attachments, :company_id, :date, :discount, :document_type, :document_number,
          :financial_accounts, :first_due_date, :identifier, :installments, :third_party_id, :total_value
        ]

        attribute? :id, Dry::Types['coercible.integer'].optional
        attribute? :addition, Dry::Types['coercible.float'].optional
        attribute? :additional_information, Dry::Types['coercible.string'].optional
        attribute? :apportionments, Dry::Types['strict.array'].of(Nova::API::Resource::Bill::Apportionment).optional
        attribute? :attachments, Dry::Types['strict.array'].of(Dry::Types['coercible.string']).optional
        attribute :company_id, Dry::Types['coercible.integer']
        attribute :date, Dry::Types['coercible.string'].constrained(format: DATE_REGEX)
        attribute? :discount, Dry::Types['coercible.float'].optional
        attribute :document_type, Dry::Types['coercible.integer']
        attribute? :document_number, Dry::Types['coercible.string']
        attribute? :financial_accounts, Dry::Types['strict.array'].of(Nova::API::Resource::Bill::FinancialAccount).optional
        attribute :first_due_date, Dry::Types['coercible.string'].constrained(format: DATE_REGEX)
        attribute? :identifier, Dry::Types['coercible.string'].optional
        attribute? :installments, Dry::Types['strict.array'].of(Nova::API::Resource::DirectBill::Installment).optional
        attribute :third_party_id, Dry::Types['coercible.integer']
        attribute :total_value, Dry::Types['coercible.float']

        def self.endpoint
          nil
        end
      end
    end
  end
end
