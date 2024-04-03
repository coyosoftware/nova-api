module Nova
  module API
    class Configuration
      attr_accessor :api_key, :subdomain, :use_staging, :debug
      attr_reader :host
      attr_reader :scheme

      def use_staging?
        [true, 'true'].include?(use_staging)
      end

      def debug?
        [true, 'true'].include?(debug)
      end
    end
  end
end
