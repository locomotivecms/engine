module Locomotive
  module MembershipPolicies
    class AbstractPolicy < Struct.new(:user, :record, :membership)
      include Implementation

    end
  end
end
