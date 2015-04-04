module Locomotive
  module Resources
    class ThemeAssetAPI < Grape::API

      resource :theme_assets do

        entity_klass = Locomotive::API::ThemeAssetEntity

        before do
          setup_resource_methods_for(:theme_assets)
          authenticate_locomotive_account!
        end

        desc 'Index of theme assets'
        get :index do
          auth :index?

          present theme_assets, with: entity_klass
        end

        desc 'Show a theme asset'
        params do
          requires :id, type: String, desc: 'Theme asset ID'
        end
        route_param :id do
          get do
            auth :show?

            present theme_asset, with: entity_klass, policy: current_policy
          end
        end

        desc 'Create a theme asset'
        params do
          requires :theme_asset, type: Hash do
            requires :source
            optional :local_path
            optional :content_type, type: String
            optional :folder
            optional :plain_text_name
            optional :plain_text_type
            optional :performing_plain_text
          end
        end
        post do
          authorize ThemeAsset, :create?

          form = form_klass.new(theme_asset_params)
          persist_from_form(form)

          present theme_asset, with: entity_klass, policy: current_policy(theme_asset)
        end

        desc "Update a theme asset"
        params do
          requires :id, type: String, desc: 'Theme asset ID'
          requires :theme_asset, type: Hash do
            optional :source
            optional :local_path
            optional :content_type, type: String
            optional :folder
            optional :plain_text_name
            optional :plain_text_type
            optional :performing_plain_text
          end
        end
        put ':id' do
          authorize theme_asset, :update?

          form = form_klass.new(theme_asset_params)
          persist_from_form(form)

          present theme_asset, with: entity_klass, policy: current_policy(theme_asset)
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

      end

    end
  end

end
