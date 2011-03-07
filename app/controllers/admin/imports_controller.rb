module Admin
  class ImportsController < BaseController

    sections 'settings', 'site'

    actions :show, :new, :create

    def show
      @job = Delayed::Job.where({ :job_type => 'import', :site_id => current_site.id }).last

      respond_to do |format|
        format.html do
          redirect_to new_admin_import_url if @job.nil?
        end
        format.json { render :json => {
          :step => @job.nil? ? 'done' : @job.step,
          :failed => @job && @job.last_error.present?
        } }
      end
    end

    def new; end

    def create
      begin
        Locomotive::Import::Job.run!(params[:zipfile], current_site, {
          :samples  => Boolean.set(params[:samples]),
          :reset    => Boolean.set(params[:reset])
        })

        flash[:notice] = t("flash.admin.imports.create.#{Locomotive.config.delayed_job ? 'notice' : 'done'}")

        redirect_to Locomotive.config.delayed_job ? admin_import_url : new_admin_import_url
      rescue Exception => e
        logger.error "[Locomotive import] #{e.message} / #{e.backtrace}"

        @error = e.message
        flash[:alert] = t('flash.admin.imports.create.alert')

        render 'new'
      end
    end

  end
end