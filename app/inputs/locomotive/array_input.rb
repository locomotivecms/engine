module Locomotive
  class ArrayInput < Formtastic::Inputs::StringInput

    include FormtasticBootstrap::Inputs::Base

    def to_html
      bootstrap_wrapping do
        list_html + new_field_html
      end
    end

    def list_html
      row_wrapping do
        template.content_tag :div,
          list.map { |item| item_html(item) }.join("\n").html_safe,
          class: "col-md-12 list #{'hide' if list.empty?}"
      end
    end

    def item_html(item)
      template.render options[:partial].to_s, method.to_s.singularize.to_sym => item
    end

    def new_field_html
      template.content_tag :div,
        template.content_tag(:div,
          template.text_field_tag(method.to_s.singularize, '', form_control_input_html_options),
          class: 'field col-md-10 col-xs-9') +
        template.content_tag(:div,
          template.content_tag(:a, text(:add), class: 'btn btn-primary btn-sm add', href: options[:template_url]),
          class: 'button col-md-2 col-xs-3 text-right'),
        class: 'row new-field'
    end

    def row_wrapping(&block)
      template.content_tag(:div,
        template.capture(&block).html_safe,
        class: 'row')
    end

    def trash_icon
      template.content_tag(:i, '', class: 'fa fa-trash-o')
    end

    def list
      @list ||= (options[:list] || object.send(method.to_sym))
    end

    def text(name)
      I18n.t("locomotive.shared.form.array_input.#{name}")
    end

  end
end