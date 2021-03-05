module Nova
  module API
    module SearchParams
      class CurrentAsset < Nova::API::Utils::BaseStruct
        attribute? :company_id, Dry::Types['coercible.integer'].optional
        attribute? :with_inactive, Dry::Types['strict.bool'].optional
      end
    end
  end
end
