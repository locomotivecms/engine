module Locomotive
  module Shared
    module SiteMetafieldsHelper

      def current_site_metafields_ui
        return @site_metafields_ui if @site_metafields_ui

        _ui = current_site.metafields_ui

        @site_metafields_ui = {}.tap do |ui|
          # label displayed in the sidebar section
          ui[:label] = current_site_metafields_ui_t(_ui['label'], t('locomotive.shared.sidebar.metafields'))

          # top title displayed in the metafields view
          ui[:title] = current_site_metafields_ui_t(_ui['label'], t('locomotive.current_site_metafields.index.title'))

          # hint for the editing properties page
          ui[:hint]  = current_site_metafields_ui_t(_ui['hint'], t('locomotive.current_site_metafields.index.help', default: ''))

          # icon in the sidebar
          ui[:icon]  = "fa-#{_ui['icon'].present? ? _ui['icon'] : 'newspaper-o'}"
        end
      end

      def current_site_metafields_ui_t(value, default = nil)
        (if value.is_a?(Hash)
          value[I18n.locale.to_s] || value['default']
        else
          value
        end || default).html_safe
      end

    end
  end
end
