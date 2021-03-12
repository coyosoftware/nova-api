module Nova
  module API
    module Resource
      class CurrentAsset < Nova::API::Base
        ALLOWED_ATTRIBUTES = %i[]

        attribute? :id, Dry::Types['coercible.integer'].optional
        attribute? :company, Nova::API::Resource::Company.optional
        attribute? :active, Dry::Types['strict.bool'].optional
        attribute? :image, Dry::Types['coercible.string'].optional
        attribute? :balance, Dry::Types['coercible.float'].optional

        def self.endpoint
          '/api/current_assets'
        end

        def self.statement(parameters = {})
          do_get("#{endpoint}/statement", parameters.to_h, Nova::API::Resource::Response::CurrentAssetStatement.new)
        end

        def statement(initial_date, final_date)
          protect_operation_from_missing_value

          self.class.do_get("#{endpoint}/statement", { company_id: company.id, current_asset_id: id, final_date: final_date, initial_date: initial_date }, Nova::API::Resource::Response::CurrentAssetStatement.new)
        end

        def endpoint
          "/api/current_assets"
        end
      end
    end
  end
end
