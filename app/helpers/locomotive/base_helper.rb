module Locomotive
  module BaseHelper

    def title(title = nil)
      if title.nil?
        @content_for_title
      else
        @content_for_title = title
        ''
      end
    end

    def inputs_folded?(resource)
      resource.persisted? && resource.errors.empty?
    end

    def submenu_entry(name, url, options = {}, &block)
      default_options = { :i18n => true, :css => name.dasherize.downcase }
      default_options.merge!(options)

      css = "#{'on' if name == sections(:sub)} #{options[:css]}"

      label_link = default_options[:i18n] ? t("locomotive.shared.menu.#{name}") : name
      if block_given?
        popup = content_tag(:div, capture(&block), :class => 'popup', :style => 'display: none')
        link = link_to(content_tag(:span, preserve(label_link) + content_tag(:em)) + content_tag(:em), url, :class => css)
        content_tag(:li, link + popup, :class => 'hoverable')
      else
        content_tag(:li, link_to(content_tag(:span, label_link), url, :class => css))
      end
    end

    def local_action_button(text, url, options = {})
      text = text.is_a?(Symbol) ? t(".#{text}") : text
      link_to(url, options) do
        content_tag(:em, escape_once('&nbsp;')) + text
      end
    end

    def locale_picker_link
      if current_site.locales.size > 1 && localized?
        content_tag :div, render('locomotive/shared/locale_picker_link'), :class => 'action'
      else
        nil
      end
    end

    def flash_message
      if not flash.empty?
        first_key = flash.keys.first
        content_tag :div, flash[first_key],
          :id => "flash-#{first_key}",
          :class => 'application-message'
      else
        ''
      end
    end

    def backbone_view_class_name
      action = case controller.action_name
      when 'create' then 'New'
      when 'update' then 'Edit'
      else
        controller.action_name
      end.camelize

      "Locomotive.Views.#{controller.controller_name.camelize}.#{action}View"
    end

    def backbone_view_data
      content_for?(:backbone_view_data) ? content_for(:backbone_view_data) : ''
    end

    def nocoffee_tag
      link_to 'noCoffee', 'http://www.nocoffee.fr', :id => 'nocoffee'
    end

    # sites

    def application_domain
      domain = Locomotive.config.domain
      domain += ":#{request.port}" if request.port != 80
      domain
    end

    def manage_subdomain_or_domains?
      Locomotive.config.manage_subdomain? || Locomotive.config.manage_domains?
    end

    def manage_subdomain?
      Locomotive.config.manage_subdomain?
    end

    def manage_domains?
      Locomotive.config.manage_domains?
    end

    def multi_sites?
      Locomotive.config.multi_sites?
    end

    def public_page_url(page, options = {})
      if content = options.delete(:content)
        File.join(current_site_public_url, page.fullpath.gsub('content_type_template', ''), content._slug)
      else
        File.join(current_site_public_url, page.fullpath)
      end
    end

    # memberships

    def options_for_membership_roles(options = {})
      list = (unless options[:skip_admin]
        Locomotive::Ability::ROLES.map { |r| [t("locomotive.memberships.roles.#{r}"), r] }
      else
        (Locomotive::Ability::ROLES - ['admin']).map { |r| [t("locomotive.memberships.roles.#{r}"), r] }
      end)

      options_for_select(list)
    end


  end
end