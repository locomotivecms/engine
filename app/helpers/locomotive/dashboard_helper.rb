module Locomotive
  module DashboardHelper

    def activity_to_icon(activity)
      case activity.domain
      when 'site'           then 'fa-cog'
      when 'page'           then 'fa-file-text'
      when 'content_entry'  then activity.action == 'created_public' ? 'fa-comment' : 'fa-archive'
      when 'membership'     then 'fa-user'
      when 'content_asset'  then 'fa-file-picture-o'
      end
    end

    def render_activity_sentence(activity)
      params = activity.parameters

      options = case activity.key
      when 'membership.created' then { name: activity_emphasize(params[:name]) }
      when /\Acontent_entry\./  then activity_content_entry_options(params)
      when /\Apage\./           then activity_page_options(params)
      when 'content_asset.created_bulk' then activity_bulk_content_assets_options(params)
      when 'content_asset.destroyed' then { name: activity_emphasize(params[:name]) }
      end

      activity_key_to_sentence(activity.key, options)
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

    def activity_bulk_content_assets_options(params)
      list = params[:assets].map do |asset|
        if asset[:image]
          content_tag(:li, link_to(image_tag(Locomotive::Dragonfly.resize_url(asset[:url], '60x60#'), alt: asset[:name]), asset[:url]))
        else
          content_tag(:li, link_to(truncate(asset[:name], length: 20), asset[:url]))
        end
      end.join("\n").html_safe

      {
        count:  activity_emphasize(params[:assets].size),
        list:   content_tag(:ul, list, class: 'assets')
      }
    end

  end
end
