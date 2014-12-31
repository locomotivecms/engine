module Locomotive
  module CustomFields
    class SelectOptionsController < BaseController

      before_filter :load_content_type
      before_filter :load_custom_field

      def edit
        respond_with @custom_field
      end

      def update
        @options = service.update_select_options(params[:select_options])
        respond_with @custom_field, location: -> { last_saved_location!(content_entries_path(@content_type.slug)) }
      end

      def new_option
        if params[:select_option].present?
          option = @custom_field.select_options.build(name: params[:select_option])
          render partial: 'option', locals: { select_option: option }
        else
          head :unprocessable_entity
        end
      end

      private

      def load_content_type
        @content_type ||= current_site.content_types.where(slug: params[:slug]).first
      end

      def load_custom_field
        @custom_field = @content_type.entries_custom_fields.where(name: params[:name]).first
      end

      def service
        @service ||= Locomotive::CustomFieldService.new(@custom_field)
      end

    end
  end
end
