module Locomotive
  module API
    module Resources

      class SectionResource < Grape::API

        resource :sections do

          entity_klass = Entities::SectionEntity

          before do
            setup_resource_methods_for(:sections)
            authenticate_locomotive_account!
          end

          desc 'Index of sections'
          get '/' do
            authorize Section, :index?

            present sections, with: entity_klass
          end

          desc 'Show a section'
          params do
            requires :id, type: String, desc: 'Section ID'
          end
          route_param :id do
            get do
              authorize section, :show?

              present section, with: entity_klass
            end
          end

          desc 'Create a section'
          params do
            requires :section, type: Hash do
              requires :name
              requires :slug
              requires :template
              requires :definition
            end
          end
          post do
            authorize Section, :create?

            form = form_klass.new(section_params)
            persist_from_form(form)

            present section, with: entity_klass
          end

          desc 'Update a Section (or create one)'
          params do
            requires :id, type: String, desc: 'Section ID or Slug'
            requires :section, type: Hash do
              optional :name
              optional :slug
              optional :template
              optional :definition
            end
          end
          put ':id' do
            if @section = current_site.sections.by_id_or_slug(params[:id]).first
              authorize @section, :update?
            else
              authorize Section, :create?

              @section = current_site.sections.build
            end

            form = form_klass.new(section_params)
            persist_from_form(form)

            present section, with: entity_klass
          end

          desc "Delete a section"
          params do
            requires :id, type: String, desc: 'Section ID or SLUG'
          end
          delete ':id' do
            @section = current_site.sections.by_id_or_slug(params[:id]).first

            raise ::Mongoid::Errors::DocumentNotFound.new(current_site.sections, params) if section.nil?

            object_auth :destroy?

            section.destroy

            present section, with: entity_klass
          end

          desc 'Delete all sections'
          delete '/' do
            auth :destroy_all?

            number = current_site.sections.count

            current_site.sections.destroy_all

            present({ deletions: number })
          end

        end

      end

    end
  end
end
