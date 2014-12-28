module Locomotive
  module BaseHelper

    def body_class
      action = case controller.action_name
      when 'create' then 'New'
      when 'update' then 'Edit'
      else controller.action_name
      end

      [self.controller.controller_name, action].map(&:dasherize).join(' ')
    end

    def title(title = nil)
      if title.nil?
        @content_for_title
      else
        if request.xhr?
          concat content_tag(:h1, title)
        else
          @content_for_title = title
          ''
        end
      end
    end

    def help(text)
      if text.present?
        content_tag :p, text, class: 'text'
      else
        ''
      end
    end

    #= Form helpers

    def locomotive_form_for(object, *args, &block)
      options = args.extract_options!
      options[:wrapper] = :locomotive
      simple_form_for(object, *(args << options.merge(builder: Locomotive::FormBuilder)), &block)
    end

    def form_nav_tab(name, first = false, &block)
      active = (first && params[:active_tab].blank?) || params[:active_tab] == name.to_s

      content_tag(:li, capture(&block), class: active ? 'active' : '')
    end

    def form_tab_pane(name, first = false, &block)
      active  = (first && params[:active_tab].blank?) || params[:active_tab] == name.to_s
      css     = ['tab-pane', active ? 'active' : nil].compact.join(' ')

      content_tag(:div, capture(&block), id: name, class: css)
    end

    ## Tag helpers ##

    def icon_tag(name)
      content_tag :i, '', class: ['fa', name].join(' ')
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
          class: "application-message alert alert-#{flash_key_to_bootstrap_alert(first_key)}"
      else
        ''
      end
    end

    def flash_messages_to_json
      flash.map do |(key, message)|
        [flash_key_to_bootstrap_alert(key), message]
      end.to_json
    end

    def set_error_from_flash(resource, attribute)
      if !flash.empty? && flash.alert
        flash.alert.tap do |msg|
          resource.errors.add(attribute.to_sym, msg)
          flash.delete(:alert)
        end
      end
    end

    def flash_key_to_bootstrap_alert(key)
      case key.to_sym
      when :notice  then :success
      when :alert   then :info
      when :error   then :warning
      else
        :info
      end
    end

    def backbone_view_class_name
      action = case controller.action_name
      when 'create' then 'New'
      when 'update' then 'Edit'
      else
        controller.action_name
      end.camelize

      (parts = controller.controller_path.split('/')).shift
      name  = parts.map(&:camelize).join('.')

      "Locomotive.Views.#{name}.#{action}View"
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
      image_tag("locomotive/icons/flags/#{locale}.png", class: "flag flag-#{locale}", size: size)
    end

    def nocoffee_tag
      link_to 'noCoffee', 'http://www.nocoffee.fr', id: 'nocoffee'
    end

    # accounts

    def account_avatar_url(account, size = '70x70#')
      if account.avatar?
        Locomotive::Dragonfly.resize_url account.avatar.url, size
      else
        'locomotive/user.png'
      end
    end

    def account_avatar_and_name(account, size = '70x70#')
      avatar  = image_tag(account_avatar_url(account, size), class: 'img-circle', style: 'width: 20px')
      profile = avatar + account.name
    end

    # sites

    def site_picture_url(site, size = '80x80#')
      if site.picture?
        Locomotive::Dragonfly.resize_url site.picture.url, size
      else
        'locomotive/site.png'
      end
    end

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

    # Dates

    def date_moment_format
      datetime_moment_format(I18n.t('date.formats.default'))
    end

    def datetime_moment_format(format = nil)
      (format || I18n.t('time.formats.default'))
        .gsub('%d', 'DD')
        .gsub('%m', 'MM')
        .gsub('%Y', 'YYYY')
        .gsub('%H', 'H')
        .gsub('%M', 'm')
    end

    # Other helpers

    # MongoDB crashes when performing a query on a big collection
    # where there is a sort without an index on the fields to sort.
    def empty_collection?(collection)
      # criteria ?
      if collection.respond_to?(:without_sorting)
        collection.without_sorting.empty?
      else
        collection.empty?
      end
    end

  end
end
