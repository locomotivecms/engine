module Locomotive
  module MembershipPolicies
    module Implementation

      def method_missing(method, *args, &block)
        if self.class.method_defined? method
          self.public_send method, *args, &block
        elsif method.to_s =~ /\?$/
          # false # fallback as unauthorized
          raise NotImplementedError
        else
          super
        end
      end

    end
  end
end
