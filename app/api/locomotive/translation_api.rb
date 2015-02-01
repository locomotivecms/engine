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


    resource :translations do
      entity_class = Locomotive::TranslationEntity
      before do
        authenticate_locomotive_account!
      end

      desc 'Returns list of translations'
      get :index do
        translations = current_site.translations
        authorize translations

        present translations, with: entity_class
      end

      desc "Return a translation"
      params do
        requires :id, type: String, desc: 'Translation ID'
      end
      route_param :id do
        get do
          translation = current_site.translations.where(id: params[:id])
          authorize translation

          present translation, with: entity_class
        end
      end

      desc "Create a translation"
      params do
        requires :key, type: String, desc: 'Translation key'
        requires :value, type: Hash
      end
      #TODO incomplete
      post do
        translation = current_site.translation.new()
        authorize translation
        translation
      end

    end

  end
end
