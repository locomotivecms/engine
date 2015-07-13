module Locomotive
  class PublicSubmissionAccountsController < BaseController

    account_required & within_site

    before_filter :load_content_type

    def edit
      authorize @content_type
      respond_with @content_type
    end

    def update
      authorize @content_type
      service.update(@content_type, content_type_params)
      respond_with @content_type, location: content_entries_path(current_site, @content_type.slug)
    end

    def new_account
      if params[:public_submission_account].present?
        render partial: 'account', locals: { public_submission_account: params[:public_submission_account] }
      else
        head :unprocessable_entity
      end
    end

    private

    def load_content_type
      @content_type ||= current_site.content_types.where(slug: params[:slug]).first
    end

    def service
      @service ||= Locomotive::ContentTypeService.new(current_site)
    end

    def content_type_params
      params.require(:content_type).permit(public_submission_accounts: [])
    end

  end
end
