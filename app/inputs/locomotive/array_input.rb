module Locomotive
  class ArrayInput < ::SimpleForm::Inputs::Base

    include Locomotive::SimpleForm::BootstrapHelpers
    include Locomotive::SimpleForm::HeaderLink
    include Locomotive::SimpleForm::Inputs::FasterTranslate

    def input(wrapper_options)
      array_wrapper + new_item_wrapper
    end

    def array_wrapper
      row_wrapping do
        template.content_tag :div,
          collection_to_html,
          class: array_wrapper_class
      end
    end

    def array_wrapper_class
      %w(col-md-12 list).tap do |wrapper_class|
        wrapper_class << 'hide' if collection.empty?
        wrapper_class << 'new-input-disabled' unless include_input_for_new_item?
      end.join(' ')
    end

    def collection_to_html
      _template = options[:template]
      key       = self.singularized_name

      path, locals = (if _template.respond_to?(:has_key?)
       [_template[:path].to_s, _template[:locals] || {}]
      else
        [_template.to_s, {}]
      end)

      collection.map do |item|
        template.render(path, locals.merge(key => item, item: item))
      end.join("\n").html_safe
    end

    def collection
      @collection ||= (options[:collection] || object.send(attribute_name.to_sym))
    end

    def link(wrapper_options)
      _header_link(:new_item, :array_input)
    end

    def new_item_wrapper
      return '' unless include_input_for_new_item?

      template.content_tag :div,
        template.content_tag(:div,
          new_item_input,
          class: 'field col-md-10 col-xs-9') +
        template.content_tag(:div,
          template.content_tag(:a, text(:add), class: 'btn btn-primary btn-sm add', href: options[:template_url]),
          class: 'button col-md-2 col-xs-3 text-right'),
        class: 'row new-field'
    end

    def new_item_input
      css = 'form-control input'

      if options[:select_options]
        template.select_tag(singularized_name, template.options_for_select(options[:select_options]), class: css)
      elsif data = options[:picker]
        template.select_tag('id', '', class: css, data: data)
      else
        text_options = input_html_options.dup
        text_options[:class] << css
        template.text_field_tag(singularized_name, '', text_options)
      end
    end

    def include_input_for_new_item?
      options[:template_url].present?
    end

    def singularized_name
      attribute_name.to_s.singularize.to_sym
    end

    def text(name)
      I18n.t(name, scope: 'locomotive.inputs.array')
    end

  end
end
