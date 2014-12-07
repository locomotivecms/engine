module Locomotive
  module Api
    class ThemeAssetsController < BaseController

      before_filter :load_theme_asset,  only: [:show, :update, :destroy]
      before_filter :load_theme_assets, only: [:index]

      def index
        authorize ThemeAsset
        respond_with(@theme_assets)
      end

      def show
        authorize @theme_asset
        respond_with @theme_asset
      end

      def create
        authorize ThemeAsset
        @theme_asset = ThemeAsset.new(params[:theme_asset])
        @theme_asset.from_presenter(params[:theme_asset])
        @theme_asset.site = current_site
        @theme_asset.save
        respond_with @theme_asset, location: main_app.locomotive_api_theme_assets_url
      end

      def update
        authorize @theme_asset
        @theme_asset.from_presenter(params[:theme_asset])
        @theme_asset.save
        respond_with @theme_asset, location: main_app.locomotive_api_theme_assets_url
      end

      def destroy
        authorize @theme_asset
        @theme_asset.destroy
        respond_with @theme_asset
      end

      def self.description
        {
          overall: %{Manage the assets (stylesheets, javascripts, images, fonts) used by a site},
          actions: {
            index: {
              description: %{Return all the theme assets},
              example: {
                command: %{curl 'http://mysite.com/locomotive/api/theme_assets.json?auth_token=dtsjkqs1TJrWiSiJt2gg'},
                response: %(TODO)
              }
            },
            show: {
              description: %{Return the attributes of a theme asset},
              response: ThemeAssetPresenter.getters_to_hash,
              example: {
                command: %{curl 'http://mysite.com/locomotive/api/theme_assets/4244af4ef0000002.json?auth_token=dtsjkqs1TJrWiSiJt2gg'},
                response: %(TODO)
              }
            },
            create: {
              description: %{Create a theme asset},
              params: ThemeAssetPresenter.setters_to_hash,
              example: {
                command: %{curl -d '...' 'http://mysite.com/locomotive/api/theme_assets.json?auth_token=dtsjkqs1TJrWiSiJt2gg'},
                response: %(TODO)
              }
            },
            update: {
              description: %{Update a theme asset},
              params: ThemeAssetPresenter.setters_to_hash,
              example: {
                command: %{curl -d '...' -X UPDATE 'http://mysite.com/locomotive/api/theme_assets/4244af4ef0000002.json?auth_token=dtsjkqs1TJrWiSiJt2gg'},
                response: %(TODO)
              }
            },
            destroy: {
              description: %{Delete a theme asset},
              example: {
                command: %{curl -X DELETE 'http://mysite.com/locomotive/api/theme_assets/4244af4ef0000002.json?auth_token=dtsjkqs1TJrWiSiJt2gg'},
                response: %(TODO)
              }
            }
          }
        }
      end

      private

      def load_theme_asset
        @theme_asset = current_site.theme_assets.find params[:id]
      end

      def load_theme_assets
        @theme_assets = current_site.theme_assets
      end

    end
  end
end
