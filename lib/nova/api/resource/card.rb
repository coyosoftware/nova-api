module Nova
  module API
    module Resource
      class Card < Nova::API::Resource::CurrentAsset
        ALLOWED_ATTRIBUTES = %i[]

        attribute? :description, Dry::Types['coercible.string'].optional
        attribute? :institution, Dry::Types['coercible.string'].optional

        def self.endpoint
          '/api/cards'
        end

        def self.list(parameters = {})
          do_get_search(endpoint, parameters.to_h)
        end
      end
    end
  end
end
