module Locomotive::AccountsHelper

  def admin_on?(site = current_site)
    site.memberships.detect { |m| m.admin? && m.account == current_locomotive_account }
  end

end

