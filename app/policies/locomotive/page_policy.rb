module Locomotive
  class PagePolicy < ApplicationPolicy

    class Scope < Struct.new(:user, :site)

      def resolve
        if self.user.sites.include?(site)
          site.pages
        else
          []
        end
      end
    end

  end
end
