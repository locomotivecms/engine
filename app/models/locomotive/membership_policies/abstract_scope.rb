module Locomotive
  module MembershipPolicies

    class AbstractScope < Struct.new(:user)

      def resolve
        raise NotImplementedError
      end

    end
  end
end
