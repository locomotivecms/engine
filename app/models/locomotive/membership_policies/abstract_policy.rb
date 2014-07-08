module Locomotive
  module MembershipPolicies

    class AbstractPolicy < Struct.new(:user, :record, :membership)
      include Implementation

      def touch?
        raise NotImplementedError
      end

      def create?
        raise NotImplementedError
      end

    end
  end
end
