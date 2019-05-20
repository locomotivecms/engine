module Locomotive
  module Shared
    module ActivitiesHelper

      def activity_to_icon(activity)
        case activity.domain
        when 'site'             then 'fa-cog'
        when 'page'             then 'fa-file-alt'
        when 'page_content'     then 'fa-file-alt'
        when 'editable_element' then 'fa-file-alt'
        when 'content_entry'    then activity.action == 'created_public' ? 'fa-comment' : 'fa-archive'
        when 'content_asset'    then 'fa-image'
        when 'membership'       then 'fa-user'
        when 'site_metafields'  then current_site_metafields_ui[:icon]
        end
      end

      def render_activity_sentence(activity)
        params = activity.parameters
        locale = activity.locale

        options = case activity.key
        when /\Apage\./                       then activity_page_options(params)
        when /\Acontent_entry\./              then activity_content_entry_options(params, locale)
        when 'page_content.updated'           then activity_page_content_options(params, locale)
        when 'editable_element.updated_bulk'  then activity_bulk_editable_elements_options(params)
        when 'content_asset.created_bulk'     then { count: activity_emphasize(params[:assets].size) }
        when 'content_asset.destroyed'        then { name: activity_emphasize(params[:name]) }
        when 'membership.created'             then { name: activity_emphasize(params[:name]) }
        when 'site_metafields.updated'        then { label: current_site_metafields_ui[:label].downcase }
        end

        activity_key_to_sentence(activity.key, options)
      end

      def render_activity_additional_information(activity)
        case activity.key
        when 'content_asset.created_bulk' then activity_bulk_content_assets(activity.parameters)
        # when 'editable_element.updated_bulk' then activity_bulk_editable_elements(activity.parameters)
        else nil
        end
      end

      def activity_key_to_sentence(key, options = nil)
        I18n.t(key, (options || {}).merge(scope: 'locomotive.activity')).html_safe
      end

      def activity_emphasize(text)
        content_tag(:strong, text)
      end

      def activity_page_options(params)
        if params[:_id]
          { page: link_to(params[:title], editable_elements_path(current_site, params[:_id])) }
        elsif params[:title]
          { page: activity_emphasize(params[:title]) }
        else
          nil
        end
      end

      def activity_page_content_options(params, locale)
        path = edit_page_content_path(current_site, params[:_id], content_locale: locale)
        { page: link_to(truncate(params[:title]), path).html_safe }
      end

      def activity_bulk_editable_elements_options(params)
        pages = params[:pages].map do |page|
          link_to truncate(page[:title]), editable_elements_path(current_site, page[:_id])
        end.join(', ').html_safe

        { pages: pages }
      end

      def activity_content_entry_options(params, locale)
        entry = if params[:_id]
          path = edit_content_entry_path(current_site, params[:content_type_slug], params[:_id], content_locale: locale)
          link_to(params[:label], path)
        elsif params[:label]
          activity_emphasize(params[:label])
        elsif params[:labels]
          activity_emphasize(params[:labels].join(', '))
        else
          nil
        end

        content_type = link_to(params[:content_type], content_entries_path(current_site, params[:content_type_slug]))

        { entry: entry, content_type: content_type }
      end

      def activity_bulk_content_assets(params)
        list = params[:assets].map do |asset|
          if asset[:image] && asset[:id] && current_site.content_assets.where(_id: asset[:id]).exists?
            content_tag(:li, link_to(image_tag(Locomotive::Dragonfly.resize_url(asset[:url], '60x60#'), alt: asset[:name]), asset[:url]))
          else
            content_tag(:li, link_to(truncate(asset[:name], length: 20), asset[:url]))
          end
        end.join("\n").html_safe

        content_tag(:ul, list, class: 'assets') + content_tag(:div, '', class: 'clearfix')
      end

    end
  end
end
