module Nova
  module API
    class Configuration
      attr_accessor :api_key, :subdomain
      attr_reader :host
      attr_reader :scheme
    end
  end
end
