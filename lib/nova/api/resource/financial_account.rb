module Nova
  module API
    module Resource
      class FinancialAccount < Nova::API::Base
        module REASON
          ASSET = 0
          LIABILITY = 1
          REVENUE = 2
          COST = 3
          EXPENSE = 4
          TRANSIENT = 5
          INVESTMENT = 6
          TAXES = 7
        end

        ALLOWED_ATTRIBUTES = %i[financial_account_id name]

        attribute? :id, Dry::Types['coercible.integer'].optional
        attribute :name, Dry::Types['coercible.string']
        attribute? :reason, Dry::Types['coercible.integer'].optional
        attribute? :financial_account_id, Dry::Types['coercible.integer'].optional
        attribute? :financial_account, Dry::Types['coercible.string'].optional
        attribute? :income, Dry::Types['strict.bool'].optional
        attribute? :outcome, Dry::Types['strict.bool'].optional
        attribute? :active, Dry::Types['strict.bool'].optional
        attribute? :children, Dry::Types['strict.array'].of(Nova::API::Resource::FinancialAccount).optional

        def self.endpoint
          '/api/financial_accounts'
        end

        def self.list
          do_get_search(endpoint, nil)
        end

        def self.income_accounts
          do_get_search("#{endpoint}/income_accounts", nil)
        end

        def self.payable_accounts
          do_get_search("#{endpoint}/payable_accounts", nil)
        end

        def self.receivable_accounts
          do_get_search("#{endpoint}/receivable_accounts", nil)
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

          "/api/financial_accounts/#{id}"
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
