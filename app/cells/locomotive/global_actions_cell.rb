module Locomotive
  class GlobalActionsCell < MenuCell

    attr_reader :current_locomotive_account, :current_site_url

    def show(args)
      @current_locomotive_account = args[:current_locomotive_account]
      @current_site_url           = args[:current_site_url]
      super
    end

    protected

    def build_list
      add :welcome, url: edit_my_account_path, i18n_options: {
        key:    'locomotive.shared.header.welcome',
        arg:    :name,
        value:  @current_locomotive_account.name
      }

      add :see, url: current_site_url, id: 'viewsite', target: '_blank'

      if Locomotive.config.multi_sites? && current_locomotive_account.sites.size > 1
        add :switch, url: '#', id: 'sites-picker-link'
      end

      add :help, url: 'http://doc.locomotivecms.com', class: 'tutorial', id: 'help', target: '_blank'
      add :logout, url: destroy_locomotive_session_path, data: { confirm: t('locomotive.messages.confirm') }, method: :delete
    end

    def localize_label(label, options = {})
      I18n.t("locomotive.shared.header.#{label}", options)
    end

  end
end