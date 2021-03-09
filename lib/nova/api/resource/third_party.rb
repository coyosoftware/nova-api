module Nova
  module API
    module Resource
      class ThirdParty < Nova::API::Base
        ALLOWED_ATTRIBUTES = %i[
          trading_name identification address phone social_reason municipal_inscription state_inscription email notes supplier
          customer retention whatsapp twitter facebook linkedin google instagram site csll pis cofins irpj values_past
        ]

        attribute? :id, Dry::Types['coercible.integer'].optional
        attribute :trading_name, Dry::Types['coercible.string']
        attribute? :identification, Dry::Types['coercible.string'].optional
        attribute? :address, Dry::Types['coercible.string'].optional
        attribute? :phone, Dry::Types['coercible.string'].optional
        attribute? :social_reason, Dry::Types['coercible.string'].optional
        attribute? :municipal_inscription, Dry::Types['coercible.string'].optional
        attribute? :state_inscription, Dry::Types['coercible.string'].optional
        attribute? :email, Dry::Types['coercible.string'].optional
        attribute? :notes, Dry::Types['coercible.string'].optional
        attribute? :supplier, Dry::Types['strict.bool'].optional
        attribute? :customer, Dry::Types['strict.bool'].optional
        attribute? :retention, Dry::Types['strict.bool'].optional
        attribute? :whatsapp, Dry::Types['coercible.string'].optional
        attribute? :twitter, Dry::Types['coercible.string'].optional
        attribute? :facebook, Dry::Types['coercible.string'].optional
        attribute? :linkedin, Dry::Types['coercible.string'].optional
        attribute? :google, Dry::Types['coercible.string'].optional
        attribute? :instagram, Dry::Types['coercible.string'].optional
        attribute? :site, Dry::Types['coercible.string'].optional
        attribute? :csll, Dry::Types['coercible.decimal'].optional
        attribute? :pis, Dry::Types['coercible.decimal'].optional
        attribute? :cofins, Dry::Types['coercible.decimal'].optional
        attribute? :irpj, Dry::Types['coercible.decimal'].optional
        attribute? :values_past, Dry::Types['coercible.decimal'].optional

        def self.endpoint
          '/api/third_parties'
        end

        def self.list(parameters = {})
          do_get_search(endpoint, parameters.to_h)
        end

        def self.customers(parameters = {})
          do_get_search("/api/customers", parameters.to_h)
        end

        def self.suppliers(parameters = {})
          do_get_search("/api/suppliers", parameters.to_h)
        end

        def self.create(parameters)
          model = new parameters

          model.attributes.delete(:id)

          model.save
        end

        def self.update(id, parameters)
          model = new parameters.merge(id: id)

          model.update
        end

        def self.destroy(id)
          model = initialize_empty_model_with_id(self, id)

          model.destroy
        end

        def endpoint
          protect_operation_from_missing_value

          "/api/third_parties/#{id}"
        end

        def save
          if id.nil?
            do_post(self.class.endpoint, allowed_attributes)
          else
            do_patch("#{endpoint}", allowed_attributes)
          end
        end

        def update
          protect_operation_from_missing_value

          do_patch("#{endpoint}", allowed_attributes)
        end

        def destroy
          protect_operation_from_missing_value

          do_delete("#{endpoint}")
        end
      end
    end
  end
end
