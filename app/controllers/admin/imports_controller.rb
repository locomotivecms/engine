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
      if params[:zipfile].blank?
        @error = t('errors.messages.blank')
        flash[:alert] = t('flash.admin.imports.create.alert')
        render 'new'
      else
        path = self.store_zipfile!

        job = Locomotive::Import::Job.new(path, current_site)
        Delayed::Job.enqueue job, { :site => current_site, :job_type => 'import' }

        flash[:notice] = t('flash.admin.imports.create.notice')

        redirect_to admin_import_url
      end
    end

    protected

    def store_zipfile!
      file = CarrierWave::SanitizedFile.new(params[:zipfile])
      new_file = file.copy_to(File.join(Rails.root, 'tmp', 'files', current_site.id.to_s, file.filename))
      new_file.path
    end

  end
end