module Nova
  module API
    class Configuration
      attr_accessor :api_key, :subdomain, :use_staging
      attr_reader :host
      attr_reader :scheme

      def use_staging?
        [true, 'true'].include?(use_staging)
      end
    end
  end
end
