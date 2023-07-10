module Nova
  module API
    module Resource
      class DirectReceivable < Nova::API::Resource::DirectBill
        class Installment < Nova::API::Resource::DirectBill::Installment
          ALLOWED_ATTRIBUTES = Nova::API::Resource::DirectBill::Installment::ALLOWED_ATTRIBUTES.dup.concat([:card_tax_id, :gross_value])

          attribute? :card_tax_id, Dry::Types['coercible.integer'].optional
          attribute? :gross_value, Dry::Types['coercible.float'].optional
        end

        ALLOWED_ATTRIBUTES = Nova::API::Resource::DirectBill::ALLOWED_ATTRIBUTES.dup << :gross_value

        attribute? :gross_value, Dry::Types['coercible.float'].optional
        attribute? :installments, Dry::Types['strict.array'].of(Nova::API::Resource::DirectReceivable::Installment).optional

        def self.endpoint
          '/api/receivables/save_direct'
        end

        def self.create(parameters)
          model = new parameters

          model.create
        end

        def create
          do_post(self.class.endpoint, allowed_attributes)
        end
      end
    end
  end
end
