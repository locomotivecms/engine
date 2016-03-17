module Locomotive
  module DashboardHelper

    def current_site_url
      if current_site.domains.blank?
        preview_url(current_site)
      else
        URI.join('http://' + current_site.domains.first).tap do |uri|
          uri.port = request.port if request.port != 80 && request.port != 443
        end.to_s
      end
    end

    # Activity

    def activity_to_icon(activity)
      case activity.domain
      when 'site'             then 'fa-cog'
      when 'page'             then 'fa-file-text'
      when 'editable_element' then 'fa-file-text'
      when 'content_entry'    then activity.action == 'created_public' ? 'fa-comment' : 'fa-archive'
      when 'content_asset'    then 'fa-file-picture-o'
      when 'membership'       then 'fa-user'
      when 'site_metafields'  then current_site_metafields_ui[:icon]
      end
    end

    def render_activity_sentence(activity)
      params = activity.parameters

      options = case activity.key
      when /\Apage\./                       then activity_page_options(params)
      when /\Acontent_entry\./              then activity_content_entry_options(params)
      when 'editable_element.updated_bulk'  then activity_bulk_editable_elements_options(params)
      when 'content_asset.created_bulk'     then { count: activity_emphasize(params[:assets].size) }
      when 'content_asset.destroyed'        then { name:  activity_emphasize(params[:name]) }
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

    def activity_bulk_editable_elements_options(params)
      pages = params[:pages].map do |page|
        link_to truncate(page[:title]),  editable_elements_path(current_site, page[:_id])
      end.join(', ').html_safe

      { pages: pages }
    end

    def activity_content_entry_options(params)
      entry = if params[:_id]
        link_to(params[:label], edit_content_entry_path(current_site, params[:content_type_slug], params[:_id]))
      elsif params[:label]
        activity_emphasize(params[:label])
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
