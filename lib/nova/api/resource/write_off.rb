module Nova
  module API
    module Resource
      class WriteOff < Nova::API::Base
        module DOCUMENT_TYPE
          DOC = 0
          TED = 1
          CHEQUE_DEPOSIT = 2
          CASH_DEPOSIT = 3
          CARD = 4
          BANK_SLIP = 5
          CASH = 6
          CHEQUE = 7
          RECEIPT = 8
          BANK_WRITE_OFF = 9
          STATEMENT = 11
          WITHDRAWAL = 12
          SUPPLY = 13
          PICK_UP = 14
          DEPOSIT = 15
          PIX = 19
        end

        ALLOWED_ATTRIBUTES = %i[]

        attribute? :date, Dry::Types['coercible.string'].constrained(format: DATE_REGEX).optional
        attribute? :value, Dry::Types['coercible.float'].optional
        attribute? :financial_account, Nova::API::Resource::FinancialAccount.optional
        attribute? :third_party, Nova::API::Resource::ThirdParty.optional
      end
    end
  end
end
