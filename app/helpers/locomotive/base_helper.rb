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

    #= Sidebar

    def sidebar_link_class(section)
      highlighted = case section
      when :pages         then ['pages', 'editable_elements'].include?(self.controller.controller_name)
      when :content_types then ['content_types', 'content_entries', 'public_submission_accounts', 'select_options'].include?(self.controller.controller_name)
      else
        self.controller.controller_name == section.to_s
      end

      ['sidebar-link', highlighted ? 'is-active' : ''].join(' ')
    end

    #= Form helpers

    def locomotive_form_for(object, *args, &block)
      options = args.extract_options!
      options[:wrapper] = :locomotive
      (options[:data] ||= {})[:blank_required_fields_message] = t(:blank_required_fields, scope: 'simple_form')
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
      return '' if current_site.locales.size == 1
      render 'locomotive/shared/locale_picker_link'
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
      when :notice          then :success
      when :alert, :error   then :danger
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

    # sites

    def application_domain
      domain = Locomotive.config.domain
      domain += ":#{request.port}" if request.port != 80
      domain
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
        .gsub('%H', 'HH')
        .gsub('%M', 'mm')
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

    # Display the name of the account (+ avatar) who created or updated the document
    # (content_entry, translation, ...etc) as well as the date when it occured.
    #
    # @param [ Object ] document The model
    #
    # @return [ String ] The html output
    #
    def document_stamp(document)
      distance  = distance_of_time_in_words_to_now(document.updated_at)
      update    = document.updated_at && document.updated_at != document.created_at

      if account = (document.updated_by || document.created_by)
        profile = account_avatar_and_name(account, '40x40#')
        key     = update ? :updated_by : :created_by
        t(key, scope: 'locomotive.shared.list', distance: distance, who: profile)
      else
        key = update ? :updated_at : :created_at
        t(key, scope: 'locomotive.shared.list', distance: distance)
      end
    end

    # cache keys

    def cache_key_for_sidebar
      "#{Locomotive::VERSION}/site/#{current_site._id}/sidebar/#{current_site.last_modified_at.to_i}/role/#{current_membership.role}/locale/#{::Mongoid::Fields::I18n.locale}"
    end

    def cache_key_for_sidebar_pages
      count          = current_site.pages.count
      max_updated_at = current_site.pages.max(:updated_at).try(:utc).try(:to_s, :number).to_i
      "#{Locomotive::VERSION}/site/#{current_site._id}/#{current_site.handle}/sidebar/pages-#{count}-#{max_updated_at}/locale/#{::Mongoid::Fields::I18n.locale}"
    end

    def cache_key_for_sidebar_content_types
      count          = current_site.content_types.count
      max_updated_at = current_site.content_entries.max(:updated_at).try(:utc).try(:to_s, :number).to_i
      "#{Locomotive::VERSION}/site/#{current_site._id}/#{current_site.handle}/sidebar/content_types-#{count}-#{max_updated_at}"
    end

  end
end
