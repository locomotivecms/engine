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

            # FIXME: content_type is a reserved word
            def parent_content_type
              @parent_content_type ||= current_site.content_types.by_id_or_slug(params[:slug]).first
            end

            def service
              @service ||= Locomotive::ContentEntryService.new(parent_content_type, current_account)
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
            requires :id, type: String, desc: 'Content entry ID or SLUG'
          end
          route_param :id do
            get do
              @content_entry = parent_content_type.entries.by_id_or_slug(params[:id]).first

              raise ::Mongoid::Errors::DocumentNotFound.new(parent_content_type.entries, { id: params[:id] }) if @content_entry.nil?

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

            back_to_default_site_locale

            form = form_klass.new(parent_content_type, content_entry_params)
            @content_entry = service.create!(form.serializable_hash)

            present content_entry, with: entity_klass
          end

          desc 'Update a content entry (or create one)'
          params do
            requires :id, type: String, desc: 'Content entry ID or SLUG'
            requires :content_entry, type: Hash
          end
          put ':id' do
            form = form_klass.new(parent_content_type, content_entry_params)

            if @content_entry = parent_content_type.entries.by_id_or_slug(params[:id]).first
              authorize @content_entry, :update?
              @content_entry = service.update!(@content_entry, form.serializable_hash)
            else
              authorize ContentEntry, :create?
              @content_entry = service.create!(form.serializable_hash)
            end

            present @content_entry, with: entity_klass
          end

          desc "Delete a content entry"
          params do
            requires :id, type: String, desc: 'Content entry ID or SLUG'
          end
          delete ':id' do
            @content_entry = parent_content_type.entries.by_id_or_slug(params[:id]).first

            raise ::Mongoid::Errors::DocumentNotFound.new(parent_content_type.entries, { id: params[:id] }) if @content_entry.nil?

            authorize content_entry, :destroy?

            content_entry.destroy

            present content_entry, with: entity_klass
          end

        end

      end

    end
  end
end
