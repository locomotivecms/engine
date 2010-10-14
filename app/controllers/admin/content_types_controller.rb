module Admin
  class ContentTypesController < BaseController

    sections 'contents'

    def destroy
      destroy! { admin_pages_url }
    end

  end
end
