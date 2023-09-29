module Nova
  module API
    module Resource
      class ApportionmentValue < Nova::API::Base
        ALLOWED_ATTRIBUTES = %i[name]

        attribute? :id, Dry::Types['coercible.integer'].optional
        attribute :name, Dry::Types['coercible.string']
        attribute? :active, Dry::Types['strict.bool'].optional
        attribute? :apportionment_id, Dry::Types['coercible.integer']
        attribute? :apportionment_name, Dry::Types['coercible.string']

        def self.endpoint(apportionment_id)
          "/api/apportionments/#{apportionment_id}/apportionment_values"
        end

        def self.create(apportionment_id, parameters)
          model = new parameters.merge(apportionment_id: apportionment_id)

          model.attributes.delete(:id)

          model.save
        end

        def self.update(apportionment_id, id, parameters)
          model = new parameters.merge(id: id, apportionment_id: apportionment_id)

          model.update
        end

        def self.destroy(apportionment_id, id)
          model = initialize_empty_model_with_id(self, id, apportionment_id: apportionment_id)

          model.destroy
        end

        def self.reactivate(apportionment_id, id)
          model = initialize_empty_model_with_id(self, id, apportionment_id: apportionment_id)

          model.reactivate
        end

        def endpoint
          "/api/apportionments/#{apportionment_id}/apportionment_values/#{id}"
        end

        def save
          if id.nil?
            do_post(self.class.endpoint(apportionment_id), allowed_attributes)
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

        def reactivate
          protect_operation_from_missing_value

          do_patch("#{endpoint}/reactivate", {})
        end
      end
    end
  end
end
