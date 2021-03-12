module Nova
  module API
    module SearchParams
      class Bill < Nova::API::Utils::BaseStruct
        attribute? :identifier, Dry::Types['coercible.string'].optional
      end
    end
  end
end
