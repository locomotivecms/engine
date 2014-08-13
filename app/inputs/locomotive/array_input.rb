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
          class: "col-md-12 list #{'hide' if list.empty?} #{'no-new-field' unless new_field?}"
      end
    end

    def item_html(item)
      template.render options[:partial].to_s, method.to_s.singularize.to_sym => item
    end

    def new_item_link_html
      if options[:new_item_url]
        template.content_tag :div,
          template.link_to(I18n.t(:new, scope: 'locomotive.shared.form.array_input'), options[:new_item_url]),
          class: 'pull-right'
      else
        ''
      end.html_safe
    end

    def new_field_html
      return '' unless new_field?

      template.content_tag :div,
        template.content_tag(:div,
          input_html,
          class: 'field col-md-10 col-xs-9') +
        template.content_tag(:div,
          template.content_tag(:a, text(:add), class: 'btn btn-primary btn-sm add', href: options[:template_url]),
          class: 'button col-md-2 col-xs-3 text-right'),
        class: 'row new-field'
    end

    def input_html
      if options[:select_options]
        template.select_tag 'locale', template.options_for_select(options[:select_options]), include_blank: false
      else
        template.text_field_tag(method.to_s.singularize, '', form_control_input_html_options)
      end
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

    def new_field?
      options[:template_url].present?
    end

    def bootstrap_wrapping(&block)
      form_group_wrapping do
        template.content_tag(:header, new_item_link_html + label_html + hint_html(:inline) + error_html(:inline)) <<
        template.content_tag(:span, :class => 'form-wrapper') do
          input_content(&block)
        end
      end
    end

  end
end