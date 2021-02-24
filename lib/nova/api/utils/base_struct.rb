require 'dry-struct'
require 'dry-types'

module Nova
  module API
    module Utils
      class BaseStruct < Dry::Struct
        transform_keys(&:to_sym)
      end
    end
  end
end
