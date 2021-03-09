module Nova
  module API
    module Resource
      class Receivable < Nova::API::Resource::Bill
        ALLOWED_ATTRIBUTES = Nova::API::Resource::Bill::ALLOWED_ATTRIBUTES.dup << :gross_value

        attribute? :gross_value, Dry::Types['coercible.decimal'].optional

        def self.endpoint
          '/api/receivables'
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
          model = initialize_empty_model_with_id(self, id, date: Date.today.iso8601, first_due_date: Date.today.iso8601)

          model.destroy
        end

        def endpoint
          protect_operation_from_missing_value

          "/api/receivables/#{id}"
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
