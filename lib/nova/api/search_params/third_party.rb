module Nova
  module API
    module SearchParams
      class ThirdParty < Nova::API::Utils::BaseStruct
        attribute? :q, Dry::Types['coercible.string'].optional
      end
    end
  end
end
