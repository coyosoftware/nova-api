module Nova
  module API
    module Resource
      class Company < Nova::API::Base
        ALLOWED_ATTRIBUTES = %i[]

        attribute? :active, Dry::Types['strict.bool'].optional
        attribute? :address, Dry::Types['coercible.string'].optional
        attribute? :city, Dry::Types['coercible.string'].optional
        attribute? :complement, Dry::Types['coercible.string'].optional
        attribute? :email, Dry::Types['coercible.string'].optional
        attribute? :id, Dry::Types['coercible.integer'].optional
        attribute? :identification, Dry::Types['coercible.string'].optional
        attribute? :logo, Dry::Types['coercible.string'].optional
        attribute? :municipal_inscription, Dry::Types['coercible.string'].optional
        attribute? :name, Dry::Types['coercible.string'].optional
        attribute? :neighborhood, Dry::Types['coercible.string'].optional
        attribute? :number, Dry::Types['coercible.string'].optional
        attribute? :phone, Dry::Types['coercible.string'].optional
        attribute? :social_reason, Dry::Types['coercible.string'].optional
        attribute? :state, Dry::Types['coercible.string'].optional
        attribute? :state_inscription, Dry::Types['coercible.string'].optional
        attribute? :tax_regime, Dry::Types['coercible.integer'].optional
        attribute? :trading_name, Dry::Types['coercible.string'].optional
        attribute? :zipcode, Dry::Types['coercible.string'].optional

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
