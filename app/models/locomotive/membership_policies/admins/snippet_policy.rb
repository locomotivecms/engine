module Locomotive
  module MembershipPolicies
    module Admins
      class SnippetPolicy < AbstractPolicy

        def touch?
          true
        end

        def create?
          true
        end
      end
    end
  end
end
