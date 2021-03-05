module Nova
  module API
    module Resource
      class Bank < Nova::API::Resource::CurrentAsset
        ALLOWED_ATTRIBUTES = %i[]

        attribute? :agency, Dry::Types['coercible.string'].optional
        attribute? :current_account, Dry::Types['coercible.string'].optional
        attribute? :institution do
          attribute :code, Dry::Types['coercible.string'].optional
          attribute :name, Dry::Types['coercible.string'].optional
        end
        attribute? :usage do
          attribute :code, Dry::Types['coercible.integer'].optional
          attribute :name, Dry::Types['coercible.string'].optional
        end

        def self.endpoint
          '/api/banks'
        end

        def self.list(parameters = {})
          do_get_search(endpoint, parameters.to_h)
        end
      end
    end
  end
end
