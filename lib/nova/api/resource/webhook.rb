module Nova
  module API
    module Resource
      class Webhook < Nova::API::Base
        ALLOWED_ATTRIBUTES = %i[events url]

        attribute? :id, Dry::Types['coercible.integer'].optional
        attribute :events, Dry::Types['strict.array'].of(Dry::Types['coercible.string'])
        attribute :url, Dry::Types['coercible.string']

        def self.endpoint
          '/api/webhooks'
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
          model = initialize_empty_model_with_id(self, id, events: [])

          model.destroy
        end

        def self.restore(id)
          model = initialize_empty_model_with_id(self, id, events: [])

          model.restore
        end

        def endpoint
          protect_operation_from_missing_value

          "/api/webhooks/#{id}"
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

        def restore
          protect_operation_from_missing_value

          do_patch("#{endpoint}/restore", {})
        end
      end
    end
  end
end
