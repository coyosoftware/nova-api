module Nova
  module API
    module Resource
      class Bill < Nova::API::Base
        module DOCUMENT_TYPE
          INVOICE = 0
          RECEIPT = 1
          COUPON_TAX = 2
          BILL = 3
          BILLET = 4
          CHEQUE = 5
          INITIAL_BALANCE = 6
          TRANSFERENCE = 7
          CONTRACT = 8
          OTHER = 9
          STATEMENT = 10
          ORDER_NUMBER = 11
        end

        module DUE_TYPE
          MONTHLY = 0
          BIWEEKLY = 1
          TEN_DAYS = 2
          FIXED = 3
          WEEKLY = 4
        end

        class Apportionment < Nova::API::Utils::BaseStruct
          ALLOWED_ATTRIBUTES = [:value, :apportionment_value_ids]

          attribute :apportionment_value_ids, Dry::Types['strict.array'].of(Dry::Types['coercible.integer'].optional)
          attribute :value, Dry::Types['coercible.float']
        end

        class FinancialAccount < Nova::API::Utils::BaseStruct
          ALLOWED_ATTRIBUTES = [:value, :financial_account_id]

          attribute :financial_account_id, Dry::Types['coercible.integer']
          attribute :value, Dry::Types['coercible.float']
        end

        ALLOWED_ATTRIBUTES = [
          :additional_information, :apportionments, :attachments, :company_id, :date, :document_type, :document_number, :due_type, :financial_accounts,
          :first_due_date, :forecast, :identifier, :installments, :installments_number, :third_party_id, :total_value
        ]

        attribute? :id, Dry::Types['coercible.integer'].optional
        attribute? :additional_information, Dry::Types['coercible.string'].optional
        attribute? :apportionments, Dry::Types['strict.array'].of(Nova::API::Resource::Bill::Apportionment).optional
        attribute? :attachments, Dry::Types['strict.array'].of(Dry::Types['coercible.string']).optional
        attribute :company_id, Dry::Types['coercible.integer']
        attribute :date, Dry::Types['coercible.string'].constrained(format: DATE_REGEX)
        attribute :document_type, Dry::Types['coercible.integer']
        attribute? :document_number, Dry::Types['coercible.string']
        attribute? :due_type, Dry::Types['coercible.integer']
        attribute? :financial_accounts, Dry::Types['strict.array'].of(Nova::API::Resource::Bill::FinancialAccount).optional
        attribute :first_due_date, Dry::Types['coercible.string'].constrained(format: DATE_REGEX)
        attribute :forecast, Dry::Types['strict.bool']
        attribute? :identifier, Dry::Types['coercible.string'].optional
        attribute? :installments, Dry::Types['strict.array'].of(Nova::API::Resource::Installment).optional
        attribute :installments_number, Dry::Types['coercible.integer']
        attribute :third_party_id, Dry::Types['coercible.integer']
        attribute :total_value, Dry::Types['coercible.float']

        def self.endpoint
          '/api/bills'
        end
      end
    end
  end
end
