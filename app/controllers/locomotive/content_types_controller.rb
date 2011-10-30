module Locomotive
  class ContentTypesController < BaseController

    sections 'contents'

    def destroy
      destroy! { locomotive_pages_url }
    end

  end
end
