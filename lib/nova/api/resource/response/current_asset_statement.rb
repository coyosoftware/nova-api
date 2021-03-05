module Nova
  module API
    module Resource
      module Response
        class CurrentAssetStatement < Nova::API::Utils::BaseStruct
          attribute? :last_statement, Dry::Types['coercible.decimal'].optional
          attribute? :write_offs, Dry::Types['strict.array'].of(Nova::API::Resource::WriteOff).optional
        end
      end
    end
  end
end