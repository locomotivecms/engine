module Locomotive
  module DashboardHelper

    def render_activity_sentence(activity)
      params = activity.parameters

      case activity.key
      when 'site.created'
        I18n.t('locomotive.activity.site.created')

      when 'page.created'
        I18n.t 'locomotive.activity.page.created',
          page: link_to(params[:title], editable_elements_path(current_site, params[:_id]))
      when 'page.updated'
        I18n.t 'locomotive.activity.page.updated',
          page: link_to(params[:title], editable_elements_path(current_site, params[:_id]))
      when 'page.destroyed'
        I18n.t 'locomotive.activity.page.destroyed',
          page: content_tag(:strong, params[:title])

      when 'content_asset.created_bulk'
        I18n.t 'locomotive.activity.content_asset.created_bulk',
          count: content_tag(:strong, params[:assets].size)
      when 'content_asset.destroyed'
        I18n.t 'locomotive.activity.content_asset.destroyed',
          filename: content_tag(:strong, params[:name])

      else "Unknown activity #{activity.key}"
      end.html_safe
    end

  end
end
