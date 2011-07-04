module Admin::AccountsHelper

  def admin_on?(site = current_site)
    site.memberships.detect { |m| m.admin? && m.account == current_admin }
  end

end

