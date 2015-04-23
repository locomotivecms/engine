module Locomotive
  module API
    module Resources

      class ContentAssetResource < Grape::API

        resource :content_assets do
          entity_klass = Entities::ContentAssetEntity

          before do
            setup_resource_methods_for(:content_assets)
          end

          desc 'Index of content assets'
          get do
            authenticate_locomotive_account!
            authorize ContentAsset, :index?

            present content_assets, with: entity_klass
          end

          desc 'Show a content asset'
          params do
            requires :id, type: String, desc: 'Content asset ID'
          end
          route_param :id do
            get do
              authenticate_locomotive_account!
              authorize content_asset, :show?

              present content_asset, with: entity_klass
            end
          end

          desc 'Create a content asset'
          params do
            requires :content_asset, type: Hash do
              requires :source
            end
          end
          post do
            authorize ContentAsset, :create?
            form = form_klass.new(content_asset_params)
            persist_from_form(form)

            present content_asset, with: entity_klass
          end

          desc 'Update a content asset'
          params do
            requires :content_asset, type: Hash do
              requires :source
            end
          end
          put ':id' do
            authenticate_locomotive_account!
            authorize content_asset, :update?

            form = form_klass.new(content_asset_params)
            persist_from_form(form)

            present content_asset, with: entity_klass
          end

          desc 'Delete a content asset'
          params do
            requires :id, type: String, desc: 'Content asset ID'
          end
          delete ':id' do
            authenticate_locomotive_account!
            authorize content_asset, :destroy?

            content_asset.destroy

            present content_asset, with: entity_klass
          end

        end

      end

    end
  end
end
