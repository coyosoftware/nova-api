module Nova
  module API
    module Resource
      class Company < Nova::API::Base
        ALLOWED_ATTRIBUTES = %i[]

        attribute? :active, Dry::Types['strict.bool'].optional
        attribute? :address, Dry::Types['coercible.string'].optional
        attribute? :id, Dry::Types['coercible.integer'].optional
        attribute? :identification, Dry::Types['coercible.string'].optional
        attribute? :name, Dry::Types['coercible.string'].optional
        attribute? :phone, Dry::Types['coercible.string'].optional
        attribute? :social_contract_date, Dry::Types['coercible.string'].constrained(format: DATE_REGEX).optional
        attribute? :social_contract_number, Dry::Types['coercible.string'].optional
        attribute? :state_inscription, Dry::Types['coercible.string'].optional
        attribute? :trading_name, Dry::Types['coercible.string'].optional

        def self.endpoint
          '/api/companies'
        end

        def self.list
          do_get_search(endpoint, nil)
        end
      end
    end
  end
end
