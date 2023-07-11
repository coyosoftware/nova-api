module Nova
  module API
    module Resource
      class Card < Nova::API::Resource::CurrentAsset
        class Tax < Nova::API::Utils::BaseStruct
          module TYPE
            DEBIT = 0
            CREDIT = 1
            CREDIT_WITH_INSTALLMENTS = 2
            BANK_SLIP = 3
            PIX = 4
          end

          ALLOWED_ATTRIBUTES = %i[]

          attribute :percentage, Dry::Types['coercible.float']
          attribute :fixed, Dry::Types['coercible.float']
          attribute :type, Dry::Types['coercible.integer']
          attribute :id, Dry::Types['coercible.integer']
          attribute :installments, Dry::Types['coercible.integer']
          attribute :days, Dry::Types['coercible.integer']

          def debit?
            type == TYPE::DEBIT
          end

          def credit?
            type == TYPE::CREDIT || type == TYPE::CREDIT_WITH_INSTALLMENTS
          end

          def bank_slip?
            type == TYPE::BANK_SLIP
          end

          def pix?
            type == TYPE::PIX
          end
        end

        ALLOWED_ATTRIBUTES = %i[]

        attribute? :description, Dry::Types['coercible.string'].optional
        attribute? :institution, Dry::Types['coercible.string'].optional
        attribute :taxes, Dry::Types['strict.array'].of(Nova::API::Resource::Card::Tax)

        def self.endpoint
          '/api/cards'
        end

        def self.list(parameters = {})
          do_get_search(endpoint, parameters.to_h)
        end
      end
    end
  end
end
