module Nova
  module API
    module Resource
      class WriteOff < Nova::API::Base
        ALLOWED_ATTRIBUTES = %i[]

        attribute? :date, Dry::Types['coercible.string'].constrained(format: DATE_REGEX).optional
        attribute? :value, Dry::Types['coercible.decimal'].optional
        attribute? :financial_account, Nova::API::Resource::FinancialAccount.optional
        attribute? :third_party, Nova::API::Resource::ThirdParty.optional
      end
    end
  end
end
