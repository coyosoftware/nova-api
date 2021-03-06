module Nova
  module API
    module Resource
      class Apportionment < Nova::API::Base
        ALLOWED_ATTRIBUTES = %i[name]

        attribute? :id, Dry::Types['coercible.integer'].optional
        attribute :name, Dry::Types['coercible.string']
        attribute? :active, Dry::Types['strict.bool'].optional
        attribute? :values, Dry::Types['strict.array'].of(Nova::API::Resource::ApportionmentValue).optional

        def self.endpoint
          '/api/apportionments'
        end

        def self.list(parameters = {})
          do_get_search(endpoint, parameters.to_h)
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

        def self.reactivate(id)
          model = initialize_empty_model_with_id(self, id)

          model.reactivate
        end

        def endpoint
          protect_operation_from_missing_value

          "/api/apportionments/#{id}"
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

        def reactivate
          protect_operation_from_missing_value

          do_patch("#{endpoint}/reactivate", {})
        end
      end
    end
  end
end
