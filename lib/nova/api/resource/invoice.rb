module Nova
  module API
    module Resource
      class Invoice < Nova::API::Base
        module STATUS
          AUTHORIZED = 2
          CANCELLED = 3 
        end

        module TYPE
          PRODUCT = 0
          SERVICE = 1
          PRODUCT_REFUND = 2
        end

        ALLOWED_ATTRIBUTES = %i[danfe_url key number series status type url xml_url]

        attribute? :id, Dry::Types['coercible.integer'].optional
        attribute :bill_id, Dry::Types['coercible.integer']
        attribute? :danfe_url, Dry::Types['coercible.string'].optional
        attribute? :key, Dry::Types['coercible.string'].optional
        attribute :number, Dry::Types['coercible.string']
        attribute :series, Dry::Types['coercible.string']
        attribute :status, Dry::Types['coercible.integer']
        attribute :type, Dry::Types['coercible.integer']
        attribute? :url, Dry::Types['coercible.string'].optional
        attribute? :xml_url, Dry::Types['coercible.string'].optional
      end
    end
  end
end
