module Nova
  module API
    module SearchParams
      class CurrentAssetStatement < Nova::API::Utils::BaseStruct
        attribute :company_id, Dry::Types['coercible.integer']
        attribute :current_asset_id, Dry::Types['coercible.integer']
        attribute :initial_date, Dry::Types['coercible.string'].constrained(format: DATE_REGEX)
        attribute :final_date, Dry::Types['coercible.string'].constrained(format: DATE_REGEX)
      end
    end
  end
end
