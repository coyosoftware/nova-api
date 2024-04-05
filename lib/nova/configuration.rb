module Nova
  module API
    class Configuration
      attr_accessor :api_key, :use_staging, :debug
      attr_reader :subdomain

      def subdomain=(value)
        Kernel.p "Changed subdomain from #{@subdomain} to #{value}" if debug?

        @subdomain = value
      end

      def use_staging?
        [true, 'true'].include?(use_staging)
      end

      def debug?
        [true, 'true'].include?(debug)
      end
    end
  end
end
