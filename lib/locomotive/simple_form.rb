module Locomotive
  module SimpleForm
    module BootstrapHelpers

      def row_wrapping(options = {}, &block)
        options.merge!(class: 'row')
        template.content_tag(:div,
          template.capture(&block).html_safe,
          options)
      end

      def col_wrapping(class_name, column = 6, &block)
        template.content_tag(:div,
          template.capture(&block).html_safe,
          class: "col-md-#{column} #{class_name}")
      end

    end

    module HeaderLink

      def _header_link(name, type)
        if _options = options[name]
          label = _options[:label] || I18n.t(:edit, scope: ['locomotive.shared.form', type])
          url   = _options[:url]
          template.link_to(label, url, class: 'action')
        else
          ''
        end
      end

    end

    module Inputs

      module FasterTranslate

        def translate_from_namespace(namespace, default = '')
          if (model_names = lookup_model_names)[0] == 'locomotive'
            model_name = model_names.join('.')

            _key = [
              Locomotive::VERSION,
              I18n.locale,
              template.instance_variable_get(:"@virtual_path"),
              namespace,
              model_name,
              reflection_or_attribute_name].join('/')

            Rails.cache.fetch(_key) do
              lookups = [:"#{model_name}.#{lookup_action}.#{reflection_or_attribute_name}"]
              lookups << :"#{model_name}.#{reflection_or_attribute_name}"
              lookups << default

              t(lookups.shift, scope: :"#{i18n_scope}.#{namespace}", default: lookups).presence
            end
          else
            super
          end
        end

      end

      ::SimpleForm::FormBuilder.mappings.values.uniq.each do |klass|
        klass.send(:include, FasterTranslate)
      end
    end

  end

  class FormBuilder < ::SimpleForm::FormBuilder

    def inputs(name = nil, options = {}, &block)
      html = template.content_tag(:legend, template.content_tag(:span, name))
      html += template.capture(&block)

      options[:class] ||= 'inputs'

      template.content_tag(:fieldset, html, options)
    end

    def actions(options = {}, &block)
      if options[:back_url]
        actions_with_back_button(options)
      else
        options[:class] ||= 'text-right form-actions'
        template.content_tag(:div, options, &block)
      end
    end

    def actions_with_back_button(options = {})
      back_button = back_button_action(options)

      template.content_tag(:div, action +
        '&nbsp;'.html_safe +
        translate_button(:or) +
        '&nbsp;'.html_safe +
        back_button, class: 'text-right form-actions')
    end

    def back_button_action(options = {})
      label  = translate_button(:cancel)
      url    = options[:back_url]

      if options[:use_stored_location]
        url = template.last_saved_location(url)
      end

      template.link_to(label, url)
    end

    def action(options = {})
      action        = object.persisted? ? :update : :create
      label         = options[:label] || translate_button(action)
      loading_text  = translate_button(:loading_text)

      template.content_tag :button, label,
        type:   'submit',
        class:  options[:change_class] || "btn btn-primary btn-sm #{options[:class]}",
        data:   { loading_text: loading_text }
    end

    def submit_text(action = :submit)
      translate_button(action)
    end

    def translate_button(key)
      template.t("simple_form.buttons.defaults.locomotive.#{key}")
    end

    # Extract the model names from the object_name mess, ignoring numeric and
    # explicit child indexes.
    # Prefix it by locomotive
    #
    # Example:
    #
    # route[blocks_attributes][0][blocks_learning_object_attributes][1][foo_attributes]
    # ["locomotive", "route", "blocks", "blocks_learning_object", "foo"]
    #
    def lookup_model_names #:nodoc:
      @lookup_model_names ||= begin
        child_index = options[:child_index]
        names = object_name.to_s.scan(/(?!\d)\w+/).flatten
        names.unshift('locomotive')
        names.delete(child_index) if child_index
        names.each { |name| name.gsub!('_attributes', '') }
        names.freeze
      end
    end

  end
end
