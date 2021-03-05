require 'dry-struct'
require 'dry-types'

module Nova
  module API
    module Utils
      class BaseStruct < Dry::Struct
        DATE_REGEX = /\A\d{4}-\d{2}-\d{2}\z/

        transform_keys(&:to_sym)
      end
    end
  end
end
