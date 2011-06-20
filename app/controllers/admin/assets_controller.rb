module Admin # TODO
  class AssetsController < BaseController

    sections 'assets'

    respond_to :json, :only => :update

    def create
      create! { admin_assets_url }
    end

    def update
      update! { admin_assets_url }
    end

    protected

  end
end
