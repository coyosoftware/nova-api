module Nova
  module API
    module Resource
      class Installment < Nova::API::Base
        ALLOWED_ATTRIBUTES = %i[due_date gross_value number value]

        attribute? :id, Dry::Types['coercible.integer'].optional
        attribute :due_date, Dry::Types['coercible.string'].constrained(format: DATE_REGEX)
        attribute? :gross_value, Dry::Types['coercible.float'].optional
        attribute :number, Dry::Types['coercible.integer']
        attribute :value, Dry::Types['coercible.float']

        class WriteOffInstallment < Nova::API::Base
          ALLOWED_ATTRIBUTES = [:addition, :attachments, :date, :discount, :extra_installment, :write_offs]

          attribute? :id, Dry::Types['coercible.integer'].optional
          attribute? :addition, Dry::Types['coercible.float'].optional
          attribute? :attachments, Dry::Types['strict.array'].of(Dry::Types['coercible.string']).optional
          attribute :date, Dry::Types['coercible.string'].constrained(format: DATE_REGEX)
          attribute? :discount, Dry::Types['coercible.float'].optional
          attribute? :extra_installment do
            attribute :due_date, Dry::Types['coercible.string'].constrained(format: DATE_REGEX)
            attribute :value, Dry::Types['coercible.float']
          end
          attribute :write_offs, Dry::Types['strict.array'] do
            attribute? :card_tax_id, Dry::Types['coercible.integer'].optional
            attribute :current_asset_id, Dry::Types['coercible.integer']
            attribute? :document_number, Dry::Types['coercible.string']
            attribute :document_type, Dry::Types['coercible.integer']
            attribute :value, Dry::Types['coercible.float']
          end

          def self.endpoint
            Installment.endpoint
          end

          def write_off
            protect_operation_from_missing_value

            do_post("#{self.class.endpoint}/#{id}/write_off", allowed_attributes)
          end
        end

        def self.endpoint
          '/api/installments'
        end

        def self.write_off(id, parameters)
          model = WriteOffInstallment.new(parameters.merge(id:))

          model.write_off
        end

        def write_off(parameters)
          model = WriteOffInstallment.new(parameters.merge(id:))

          model.write_off
        end
      end
    end
  end
end
