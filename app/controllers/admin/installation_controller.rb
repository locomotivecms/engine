module Admin
  class InstallationController < BaseController

    layout '/admin/layouts/box'

    skip_before_filter :require_site

    skip_before_filter :require_admin

    skip_before_filter :verify_authenticity_token

    skip_before_filter :validate_site_membership

    before_filter :is_step_already_done?

    before_filter :allow_installation?

    skip_load_and_authorize_resource

    def show
      request.get? ? self.handle_get : self.handle_post
    end

    protected

    def handle_get
      case params[:step].to_i
      when 1 then @account = Account.new
      when 2 then @site = Site.new
      end
      render "step_#{params[:step]}"
    end

    def handle_post
      case params[:step].to_i
      when 1 # create account
        @account = Account.create(params[:account])
        if @account.valid?
          redirect_to admin_installation_step_url(2)
        else
          render 'step_1'
        end
      when 2 # create site
        @site = Site.create_first_one(params[:site])

        if @site.valid?
          Site.install_template(@site, params)

          redirect_to last_url
        else
          logger.error "Unable to create the first website: #{@site.errors.inspect}"
          render 'step_2'
        end
      end
    end

    def is_step_already_done?
      case params[:step].to_i
      when 1 # already an account in db
        if account = Account.first
          @step_done = I18n.t('admin.installation.step_1.done', :name => account.name, :email => account.email)
          render 'step_1' and return false
        end
      else
        true
      end
    end

    def allow_installation?
      redirect_to admin_pages_url if Site.count > 0 && Account.count > 0
    end

    def last_url
      if Locomotive.config.manage_domains?
        admin_session_url(:host => Site.first.domains.first, :port => request.port)
      else
        admin_session_url
      end
    end

  end
end
