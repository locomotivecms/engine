module Locomotive
  module API
    module Resources

      class ContentTypeResource < Grape::API

        resource :content_types do

          entity_klass = Entities::ContentTypeEntity

          before do
            setup_resource_methods_for(:content_types)
            authenticate_locomotive_account!
          end

          desc 'Index of content_types'
          get '/' do
            authorize ContentType, :index?

            present content_types, with: entity_klass
          end

          desc 'Show a content_type'
          params do
            requires :id, type: String, desc: 'ContentTypeResource ID'
          end
          route_param :id do
            get do
              authorize content_type, :show?

              present content_type, with: entity_klass
            end
          end

          desc 'Create a content_type'
          params do
            requires :content_type, type: Hash do
              requires :name
              requires :slug
              optional :description
              requires :fields, type: Array do
                requires :name
                requires :type
                optional :label
                optional :hint
                optional :required
                optional :localized
                optional :unique
                optional :default
                optional :position
                optional :text_formatting
                optional :select_options
                optional :target
                optional :inverse_of
                optional :order_by
                optional :ui_enabled
                optional :group
              end
              optional :order_by
              optional :order_direction
              optional :group_by
              optional :label_field_name
              optional :entry_template
              optional :raw_item_template # deprecated
              optional :display_settings
              optional :filter_fields
              optional :public_submission_enabled
              optional :public_submission_account_emails
              optional :public_submission_title_template
            end
          end
          post do
            authorize ContentType, :create?

            form = form_klass.new(current_site, content_type_params)
            persist_from_form(form)

            present content_type, with: entity_klass
          end

          desc 'Update a ContentTypeResource (or create one)'
          params do
            requires :id, type: String, desc: 'ContentTypeResource ID or Slug'
            requires :content_type, type: Hash do
              requires :name
              optional :slug
              optional :description
              optional :fields, type: Array do
                requires :name
                optional :type
                optional :label
                optional :hint
                optional :required
                optional :localized
                optional :unique
                optional :default
                optional :position
                optional :text_formatting
                optional :select_options
                optional :target
                optional :inverse_of
                optional :order_by
                optional :ui_enabled
                optional :group
                optional :_destroy
              end
              optional :order_by
              optional :order_direction
              optional :group_by
              optional :label_field_name
              optional :entry_template
              optional :raw_item_template # deprecated
              optional :display_settings
              optional :filter_fields
              optional :public_submission_enabled
              optional :public_submission_account_emails
              optional :public_submission_title_template
            end
          end
          put ':id' do
            if @content_type = current_site.content_types.by_id_or_slug(params[:id]).first
              authorize @content_type, :update?
            else
              authorize ContentType, :create?
              @content_type = current_site.content_types.build
            end

            form = form_klass.new(current_site, content_type_params)
            persist_from_form(form)

            present content_type, with: entity_klass
          end

          desc "Delete a content_type"
          params do
            requires :id, type: String, desc: 'ContentType ID or SLUG'
          end
          delete ':id' do
            content_type = current_site.content_types.by_id_or_slug(params[:id]).first

            raise ::Mongoid::Errors::DocumentNotFound.new(current_site.content_types, params) if content_type.nil?

            authorize content_type, :destroy?

            content_type.destroy

            present content_type, with: entity_klass
          end

          desc 'Delete all content types'
          delete '/' do
            auth :destroy_all?

            number = current_site.content_types.count

            current_site.content_types.destroy_all

            present({ deletions: number })
          end

        end

      end

    end
  end
end
