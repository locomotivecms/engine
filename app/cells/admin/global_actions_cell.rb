class Admin::GlobalActionsCell < ::Admin::MenuCell

  attr_reader :current_admin, :current_site_url

  def show(args)
    @current_admin      = args[:current_admin]
    @current_site_url   = args[:current_site_url]
    super
  end

  protected

  def build_list
    add :welcome, :url => edit_admin_my_account_url, :i18n_options => {
      :key => 'admin.shared.header.welcome',
      :arg => :name,
      :value => @current_admin.name
    }

    add :see, :url => current_site_url, :id => 'viewsite', :target => '_blank'

    if Locomotive.config.multi_sites? && current_admin.sites.size > 1
      add :switch, :url => '#', :id => 'sites-picker-link'
    end

    add :help, :url => '#', :class => 'tutorial', :id => 'help'
    add :logout, :url => destroy_admin_session_url, :confirm => t('admin.messages.confirm')
  end

  def localize_label(label, options = {})
    I18n.t("admin.shared.header.#{label}", options)
  end

end
