module Locomotive
  module API
    module Resources

      class ThemeAssetResource < Grape::API

        resource :theme_assets do

          entity_klass = Entities::ThemeAssetEntity

          before do
            setup_resource_methods_for(:theme_assets)
            authenticate_locomotive_account!
          end

          desc 'Index of theme assets'
          get '/' do
            auth :index?

            present theme_assets, with: entity_klass
          end

          desc 'Get the checksums of all theme assets'
          get '/checksums' do
            auth :index?

            current_site.theme_assets.checksums
          end


          desc 'Show a theme asset'
          params do
            requires :id, type: String, desc: 'Theme asset ID'
          end
          route_param :id do
            get do
              auth :show?

              present theme_asset, with: entity_klass
            end
          end

          desc 'Create a theme asset'
          params do
            requires :theme_asset, type: Hash do
              requires :source
              optional :folder
              optional :checksum
            end
          end
          post do
            authorize ThemeAsset, :create?

            form = form_klass.new(theme_asset_params)
            persist_from_form(form)

            present theme_asset, with: entity_klass
          end

          desc "Update a theme asset"
          params do
            requires :id, type: String, desc: 'Theme asset ID'
            requires :theme_asset, type: Hash do
              optional :source
              optional :folder
              optional :checksum
            end
          end
          put ':id' do
            authorize theme_asset, :update?

            form = form_klass.new(theme_asset_params)
            persist_from_form(form)

            present theme_asset, with: entity_klass
          end

          desc "Delete a theme asset"
          params do
            requires :id, type: String, desc: 'Theme asset ID'
          end
          delete ':id' do
            object_auth :destroy?

            theme_asset.destroy

            present theme_asset, with: entity_klass
          end

          desc 'Delete all theme assets'
          delete '/' do
            auth :destroy_all?

            number = current_site.theme_assets.count

            current_site.theme_assets.destroy_all

            present({ deletions: number })
          end

        end

      end

    end
  end
end
