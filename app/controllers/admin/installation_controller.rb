module Admin
  class InstallationController < BaseController

    layout '/admin/layouts/box'

    skip_before_filter :require_site

    skip_before_filter :authenticate_admin!

    skip_before_filter :verify_authenticity_token

    skip_before_filter :validate_site_membership

    before_filter :is_step_already_done?

    before_filter :allow_installation?

    def show
      request.get? ? self.handle_get : self.handle_post
    end

    protected

    def handle_get
      case params[:step].to_i
      when 2 then @account = Account.new
      when 3 then @site = Site.new
      end
      render "step_#{params[:step]}"
    end

    def handle_post
      case params[:step].to_i
      when 2 # create account
        @account = Account.create(params[:account])
        if @account.valid?
          redirect_to admin_installation_step_url(3)
        else
          render 'step_2'
        end
      when 3 # create site
        @site = Site.new(params[:site])
        @site.memberships.build :account => Account.first, :admin => true
        @site.save

        if @site.valid?
          begin
            job = Locomotive::Import::Job.new(params[:zipfile], @site, { :samples => true })
            Delayed::Job.enqueue job, { :site => @site, :job_type => 'import' }
          rescue Exception => e
            logger.error "Import failed because of #{e.message}"
          end

          redirect_to admin_session_url(:host => Site.first.domains.first, :port => request.port)
        else
          render 'step_3'
        end
      end
    end

    def is_step_already_done?
      case params[:step].to_i
      when 2 # already an account in db
        if Account.count > 0
          @step_done = t('admin.installation.step_2.done', Account.first.attributes)
          render 'step_2' and return false
        end
      else
        true
      end
    end

    def allow_installation?
      redirect_to admin_pages_url if Site.count > 0 && Account.count > 0
    end

  end
end
