module Locomotive
  class ContentTypesController < BaseController

    sections 'contents'

    def destroy
      destroy! { pages_url }
    end

  end
end
