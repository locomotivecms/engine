module Admin
  class SnippetsController < BaseController

    sections 'settings', 'theme_assets'

    respond_to :json, :only => :update

    def destroy
      destroy! do |format|
        format.html { redirect_to admin_theme_assets_url }
      end
    end

  end
end
