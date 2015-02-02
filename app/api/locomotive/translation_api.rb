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
      model_class = Locomotive::Translation
      entity_class = Locomotive::TranslationEntity

      before do
        authenticate_locomotive_account!
      end

      desc 'Returns list of translations'
      get :index do
        translations = current_site.translations
        authorize translations, :index?

        present translations, with: entity_class
      end

      desc "Return a translation"
      params do
        requires :id, type: String, desc: 'Translation ID'
      end
      route_param :id do
        get do
          translation = current_site.translations.where(id: params[:id])
          authorize translation, :show?

          present translation, with: entity_class
        end
      end

      def repository
        @repository ||= TranslationRepository.new(current_site)
      end

      repository.all
      repository.create(permitted_params[:translation])

      desc "Create a translation"

      #TODO incomplete
      params do
        requires :translation, type: Hash do
          requires :key, type: String
          requires :values, type: Hash
        end
      end
      post do
        authorize Translation, :create?
        translation = TranslationForm.new(params[:translation])
        translation = current_site.translations.create(permitted_params[:translation])

      end

    end

  end
end
