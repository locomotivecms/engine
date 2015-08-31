module Locomotive
  class DevelopersDocumentationController < BaseController

    account_required & within_site

    def show
      authorize(current_site, :show_developers_documentation?)
    end

  end
end
