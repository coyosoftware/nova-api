module Nova
  module API
    module Resource
      class Permission < Nova::API::Base
        ALLOWED_ATTRIBUTES = %i[]

        attribute :action, Dry::Types['coercible.string']
        attribute :can, Dry::Types['strict.bool']
        attribute :subject, Dry::Types['coercible.string']

        def self.endpoint
          '/api/users/permissions'
        end

        def self.list
          do_get_search(endpoint, nil)
        end
      end
    end
  end
end
