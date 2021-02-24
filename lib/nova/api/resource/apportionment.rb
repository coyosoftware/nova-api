module Nova
  module API
    module Resource
      class Apportionment < Nova::API::Base
        ENDPOINT = '/api/apportionments'

        attribute? :id, Dry::Types['coercible.integer'].optional
        attribute :name, Dry::Types['coercible.string']
        attribute? :active, Dry::Types['strict.bool'].optional
        attribute? :values, Dry::Types['strict.array'].of(Dry::Types['nominal.any']).optional

        def self.list(parameters = {})
          do_get_search(ENDPOINT, parameters.to_h)
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

        def save
          if id.nil?
            do_post(ENDPOINT, attributes)
          else
            do_patch("#{ENDPOINT}/#{id}", attributes)
          end
        end

        def update
          protect_operation_from_missing_id

          do_patch("#{ENDPOINT}/#{id}", attributes)
        end

        def destroy
          protect_operation_from_missing_id

          do_delete("#{ENDPOINT}/#{id}")
        end

        def reactivate
          protect_operation_from_missing_id

          do_patch("#{ENDPOINT}/#{id}/reactivate", {})
        end
      end
    end
  end
end
