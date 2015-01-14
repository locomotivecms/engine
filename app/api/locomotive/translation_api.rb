module Locomotive
  class TranslationAPI < Grape::API

    #  needs email + token + site (env['locomotive.site'] )
    #       include Pundit
    # authorization
    # desc "hide a post"
    # post :hide do
    #   authenticate!
    #   error!( "user unauthorized for this" ) unless PostPolicy.new(current_user, @post).hide_post?
    #   @post.update hidden: true
    #   { hidden: @post.hidden }
    # end


    resource :translation do
      desc 'Returns list of translations'
      get :index do
        translations = Translation.all # TODO: to be scoped by the current_site
        present translations, with: Locomotive::TranslationEntity
      end
    end

  end
end
