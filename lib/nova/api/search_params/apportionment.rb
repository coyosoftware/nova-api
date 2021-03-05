module Nova
  module API
    module SearchParams
      class Apportionment < Nova::API::Utils::BaseStruct
        attribute? :q, Dry::Types['coercible.string'].optional
        attribute? :with_inactive, Dry::Types['strict.bool'].optional
      end
    end
  end
end
