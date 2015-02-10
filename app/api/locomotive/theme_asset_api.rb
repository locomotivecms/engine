module Locomotive
  class ThemeAssetAPI < Grape::API
    # 1. How to get policy in to entities

    resource :theme_assets do

      entity_class = Locomotive::ThemeAssetEntity

      before do
        setup_methods_for(ThemeAsset)
        authenticate_locomotive_account!
      end

      desc 'Index of theme assets'
      get :index do
        auth :index?

        present theme_assets, with: entity_class
      end
    end

  end
end
