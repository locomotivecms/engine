module Locomotive
  module API
    module Resources

      class ContentEntryResource < Grape::API

        resource '/content_types/:slug/entries' do

          entity_klass = Entities::ContentEntryEntity

          before do
            setup_resource_methods_for(:content_entries)
            authenticate_locomotive_account!
          end

          helpers do

            def content_type
              @content_type ||= current_site.content_types.by_id_or_slug(params[:slug]).first
            end

            def service
              @service ||= Locomotive::ContentEntryService.new(content_type, current_account)
            end

          end

          desc 'Index of content entries'
          get '/' do
            authorize ContentEntry, :index?

            @content_entries = service.all(params.slice(:page, :per_page, :q, :where))

            add_pagination_header(@content_entries)

            present @content_entries, with: entity_klass, serializable: true
          end

          desc 'Show a content entry'
          params do
            requires :id, type: String, desc: 'ContentEntryResource ID or SLUG'
          end
          route_param :id do
            get do
              @content_entry = content_type.entries.by_id_or_slug(params[:id]).first

              raise ::Mongoid::Errors::DocumentNotFound.new(content_type.entries, { id: params[:id] }) if @content_entry.nil?

              authorize content_entry, :show?

              present content_entry, with: entity_klass
            end
          end

          desc 'Create a content entry'
          params do
            requires :content_entry, type: Hash
          end
          post do
            authorize ContentEntry, :create?

            form = form_klass.new(content_type, content_entry_params)

            # puts form.serializable_hash.inspect

            content_entry = service.create(form.serializable_hash)

            # puts content_entry.inspect

            present content_entry, with: entity_klass
          end

          # desc 'Update a ContentEntryResource (or create one)'
          # params do
          #   requires :id, type: String, desc: 'ContentEntryResource ID or Slug'
          #   requires :content_entry, type: Hash do
          #     requires :name
          #     optional :slug
          #     optional :description
          #     optional :fields, type: Array do
          #       requires :name
          #       optional :type
          #       optional :label
          #       optional :hint
          #       optional :required
          #       optional :localized
          #       optional :unique
          #       optional :position
          #       optional :text_formatting
          #       optional :select_options
          #       optional :target
          #       optional :inverse_of
          #       optional :order_by
          #       optional :ui_enabled
          #     end
          #     optional :order_by
          #     optional :order_direction
          #     optional :group_by
          #     optional :label_field_name
          #     optional :raw_item_template
          #     optional :public_submission_account_emails
          #     optional :public_submission_accounts
          #   end
          # end
          # put ':id' do
          #   if @content_entry = current_site.content_entries.by_id_or_slug(params[:id]).first
          #     authorize @content_entry, :update?
          #   else
          #     authorize ContentEntry, :create?
          #     @content_entry = current_site.content_entries.build
          #   end

          #   form = form_klass.new(current_site, content_entry_params)
          #   persist_from_form(form)

          #   present content_entry, with: entity_klass
          # end

          # desc "Delete a content_entry"
          # params do
          #   requires :id, type: String, desc: 'ContentEntry ID'
          # end
          # delete ':id' do
          #   authorize content_entry, :destroy?

          #   content_entry.destroy

          #   present content_entry, with: entity_klass
          # end

        end

      end

    end
  end
end
