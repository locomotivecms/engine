module Locomotive
  class TranslationAPI < Grape::API
    
    desc 'Returns list of translations'
    resource :translation do
      get :index do
        translations = Translation.all # TODO: to be scoped by the current_site
        present translations, with: Locomotive::TranslationEntity
      end
    end
    
  end
end