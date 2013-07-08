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

    # Like link_to but instead of passing a label, we
    # pass the name of an Font Awesome icon.
    # If the name is a Symbol, we append "icon-" to the
    # dasherized version of the name.
    #
    # @param [ String / Symbol ] name The class name or a symbol
    # @param [ Array ] *args
    #
    # @return [ String ] The HTML <a> tag
    #
    def link_to_icon(name, *args, &block)
      name = name.is_a?(Symbol) ? "icon-#{name.to_s.dasherize}" : name
      icon = content_tag(:i, '', class: name)
      link_to(icon, *args, &block).html_safe
    end

    # Execute the code only once during the request time. It avoids duplicated
    # dom elements in the rendered rails page.
    #
    # @param [ String / Symbol ] label Unique identifier of the block
    #
    def required_once(label, &block)
      symbol = :"@block_#{label.to_s.underscore}"

      if instance_variable_get(symbol).blank?
        yield
        instance_variable_set(symbol, true)
      end
    end

    def submenu_entry(name, url, options = {}, &block)
      default_options = { i18n: true, css: name.dasherize.downcase }
      default_options.merge!(options)

      css = "#{'on' if name == sections(:sub)} #{options[:css]}"

      label_link = default_options[:i18n] ? t("locomotive.shared.menu.#{name}") : name
      if block_given?
        popup = content_tag(:div, capture(&block), class: 'popup', style: 'display: none')
        text  = content_tag(:span, preserve(label_link) + content_tag(:i, '', class: 'icon-caret-down'))
        link  = link_to(text + content_tag(:em), url, class: css)
        content_tag(:li, link + popup, class: 'hoverable')
      else
        content_tag(:li, link_to(content_tag(:span, label_link), url, class: css))
      end
    end

    def local_action_button(text, url, options = {})
      text = text.is_a?(Symbol) ? t(".#{text}") : text

      icon = options.delete(:icon) || :exclamation_sign
      icon = icon.is_a?(Symbol) ? "icon-#{icon.to_s.dasherize}" : icon

      link_to(url, options) do
        content_tag(:i, '', class: icon) + text
      end
    end

    def locale_picker_link
      if current_site.locales.size > 1 && localized?
        content_tag :div, render('locomotive/shared/locale_picker_link'), class: 'action'
      else
        nil
      end
    end

    def flash_message
      if not flash.empty?
        first_key = flash.keys.first
        content_tag :div, flash[first_key],
          id: "flash-#{first_key}",
          class: 'application-message'
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

    # Build the json version of a object. If the object owns a presenter
    # then that presenter is used instead of the default object to_json method.
    # Furthermore, if the presenter owns a as_json_for_html_view method,
    # then it is called instead of the default as_json method.
    # A html_safe is processed at the end.
    #
    # @return [ String ] The json representation of the object
    #
    def to_json(object)
      if object.respond_to?(:to_presenter)
        presenter = object.to_presenter

        if presenter.respond_to?(:as_json_for_html_view)
          presenter.as_json_for_html_view
        else
          presenter.as_json
        end.to_json
      else
        object.to_json
      end.html_safe
    end

    # Display the image of the flag representing the locale.
    #
    # @param [ String / Symbol ] locale The locale (fr, en, ...etc)
    # @param [ String ] size The width x height (by default, 24x24)
    #
    # @return [ String ] The HTML image tag with the path to the matching flag.
    #
    def flag_tag(locale, size = '24x24')
      image_tag("locomotive/icons/flags/#{locale}.png", class: 'flag', size: size)
    end

    def nocoffee_tag
      link_to 'noCoffee', 'http://www.nocoffee.fr', id: 'nocoffee'
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

    # memberships

    def options_for_membership_roles(options = {})
      list = (unless options[:skip_admin]
        Locomotive::Ability::ROLES.map { |r| [t("locomotive.memberships.roles.#{r}"), r] }
      else
        (Locomotive::Ability::ROLES - ['admin']).map { |r| [t("locomotive.memberships.roles.#{r}"), r] }
      end)

      options_for_select(list)
    end

    # locales

    # For a localized site, tell if the current content locale does not match
    # the default locale of the site. It is used by the page / snippet forms
    # to determine if we have to display the warning message letting the
    # designer know that the template is only editable in the default locale.
    #
    # @return [ Boolean ] True if it matches the condition above.
    #
    def not_the_default_current_locale?
      current_site.localized? && current_content_locale.to_s != current_site.default_locale.to_s
    end

    def localize(object, options = nil)
      if respond_to?(:current_site) && current_site && object.respond_to?(:in_time_zone)
        object = object.in_time_zone(current_site.timezone)
      end
      I18n.localize(object, options)
    end
    alias :l :localize

  end
end