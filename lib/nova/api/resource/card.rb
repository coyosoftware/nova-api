module Nova
  module API
    module Resource
      class Card < Nova::API::Resource::CurrentAsset
        class Tax < Nova::API::Utils::BaseStruct
          ALLOWED_ATTRIBUTES = %i[]

          attribute :percentage, Dry::Types['coercible.decimal']
          attribute :fixed, Dry::Types['coercible.decimal']
          attribute :type, Dry::Types['coercible.string']
          attribute :installments, Dry::Types['coercible.integer']
          attribute :days, Dry::Types['coercible.integer']
        end

        ALLOWED_ATTRIBUTES = %i[]

        attribute? :description, Dry::Types['coercible.string'].optional
        attribute? :institution, Dry::Types['coercible.string'].optional
        attribute :taxes, Dry::Types['strict.array'].of(Nova::API::Resource::Card::Tax)

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
