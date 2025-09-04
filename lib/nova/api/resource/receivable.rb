module Nova
  module API
    module Resource
      class Receivable < Nova::API::Resource::Bill
        ALLOWED_ATTRIBUTES = Nova::API::Resource::Bill::ALLOWED_ATTRIBUTES.dup << :gross_value

        attribute? :gross_value, Dry::Types['coercible.float'].optional

        def self.endpoint
          '/api/receivables'
        end

        def self.list(parameters = {})
          do_get_search(endpoint, parameters.to_h)
        end

        def self.find(id)
          do_get("#{endpoint}/#{id}", nil, initialize_empty_model_with_id(self, id, date: Date.today.iso8601, first_due_date: Date.today.iso8601))
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

        def self.save_invoice(id, parameters)
          model = initialize_empty_model_with_id(self, id, date: Date.today.iso8601, first_due_date: Date.today.iso8601)

          model.save_invoice(parameters)
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

        def save_invoice(parameters)
          protect_operation_from_missing_value

          invoice = Invoice.new(parameters.merge(bill_id: id))

          do_post("#{endpoint}/invoices", invoice.allowed_attributes, invoice)
        end
      end
    end
  end
end
