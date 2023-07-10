module Nova
  module API
    module Resource
      class DirectPayable < Nova::API::Resource::DirectBill
        def self.endpoint
          '/api/payables/save_direct'
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
