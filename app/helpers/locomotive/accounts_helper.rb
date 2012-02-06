module Locomotive
  module AccountsHelper

    def admin_on?(site = current_site)
      site.memberships.detect { |m| m.admin? && m.account == current_locomotive_account }
    end

    def options_for_account
      current_site.accounts.collect { |a| ["#{a.name} <#{a.email}>", a.id] }
    end

  end
end
