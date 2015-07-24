module Locomotive
  module DashboardHelper

    def activity_to_icon(activity)
      case activity.domain
      when 'site' then 'fa-cog'
      when 'page' then 'fa-file-text'
      when 'content_entry' then activity.action == 'created_public' ? 'fa-comment' : 'fa-archive'
      when 'membership' then 'fa-user'
      when 'content_asset' then 'fa-file-picture-o'
      end
    end

    def render_activity_sentence(activity)
      params = activity.parameters

      case activity.key
      when 'site.created'
        I18n.t('locomotive.activity.site.created')

      when 'membership.created'
        I18n.t('locomotive.activity.membership.created', name: content_tag(:strong, params[:name]))

      when 'content_entry.created'
        I18n.t 'locomotive.activity.content_entry.created',
          entry: link_to(params[:label], edit_content_entry_path(current_site, params[:content_type_slug], params[:_id])),
          content_type: link_to(params[:content_type], content_entries_path(current_site, params[:content_type_slug]))
      when 'content_entry.created_public'
        I18n.t 'locomotive.activity.content_entry.created_public',
          entry: link_to(params[:label], edit_content_entry_path(current_site, params[:content_type_slug], params[:_id])),
          content_type: link_to(params[:content_type], content_entries_path(current_site, params[:content_type_slug]))
      when 'content_entry.updated'
        I18n.t 'locomotive.activity.content_entry.updated',
          entry: link_to(params[:label], edit_content_entry_path(current_site, params[:content_type_slug], params[:_id])),
          content_type: link_to(params[:content_type], content_entries_path(current_site, params[:content_type_slug]))
      when 'content_entry.destroyed'
        I18n.t 'locomotive.activity.content_entry.destroyed',
          entry: content_tag(:strong, params[:label]),
          content_type: link_to(params[:content_type], content_entries_path(current_site, params[:content_type_slug]))
      when 'content_entry.sorted'
        I18n.t 'locomotive.activity.content_entry.sorted',
          content_type: link_to(params[:content_type], content_entries_path(current_site, params[:content_type_slug]))

      when 'page.created'
        I18n.t 'locomotive.activity.page.created',
          page: link_to(params[:title], editable_elements_path(current_site, params[:_id]))
      when 'page.updated'
        I18n.t 'locomotive.activity.page.updated',
          page: link_to(params[:title], editable_elements_path(current_site, params[:_id]))
      when 'page.destroyed'
        I18n.t 'locomotive.activity.page.destroyed',
          page: content_tag(:strong, params[:title])
      when 'page.sorted'
        I18n.t 'locomotive.activity.page.sorted'

      when 'content_asset.created_bulk'
        I18n.t('locomotive.activity.content_asset.created_bulk',
          count: content_tag(:strong, params[:assets].size)) +
        content_tag(:ul,
          params[:assets].map do |asset|
            if asset[:image]
              content_tag(:li, link_to(image_tag(Locomotive::Dragonfly.resize_url(asset[:url], '60x60#'), alt: asset[:name]), asset[:url]))
            else
              content_tag(:li, link_to(truncate(asset[:name], length: 20), asset[:url]))
            end
          end.join("\n").html_safe, class: 'assets')

      when 'content_asset.destroyed'
        I18n.t 'locomotive.activity.content_asset.destroyed',
          filename: content_tag(:strong, params[:name])

      else "Unknown activity #{activity.key}"
      end.html_safe
    end

  end
end
