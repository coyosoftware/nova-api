module Nova
  module API
    module Resource
      class Company < Nova::API::Base
        ALLOWED_ATTRIBUTES = %i[]

        attribute? :id, Dry::Types['coercible.integer'].optional
        attribute? :name, Dry::Types['coercible.string'].optional
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
