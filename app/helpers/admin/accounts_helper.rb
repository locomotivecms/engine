module Admin::AccountsHelper

  def admin_on?(site = current_site)
    site.memberships.detect { |a| a.admin? && a.account == current_admin }
  end

end

