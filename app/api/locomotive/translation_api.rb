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
      before do
        authenticate_locomotive_account!
      end
      desc 'Returns list of translations'
      get :index do
        binding.pry
        puts current_site.inspect
         translations = current_site.translations # TODO: to be scoped by the current_site

         authorize translations

         present translations, with: Locomotive::TranslationEntity
        {'hello' => true}
      end
    end

  end
end
