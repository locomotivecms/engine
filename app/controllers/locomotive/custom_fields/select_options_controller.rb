module Locomotive
  module CustomFields
    class SelectOptionsController < BaseController

      account_required & within_site

      localized

      before_action :load_content_type
      before_action :load_custom_field

      def edit
        respond_with @custom_field
      end

      def update
        @options = service.update_select_options(options_params.map(&:to_h))
        respond_with @custom_field, location: -> { last_saved_location!(default_back_location) }
      end

      def new_option
        if params[:select_option].present?
          option = @custom_field.select_options.build(name: option_name_param)
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

      def options_params
        params.require(:select_options).map { |p| p.permit(:_id, :name, :_destroy) }
      end

      def option_name_param
        params.require(:select_option)
      end

      def default_back_location
        content_entries_path(current_site, @content_type.slug)
      end

    end
  end
end
