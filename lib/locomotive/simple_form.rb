module Locomotive

  module BootstrapFormHelper

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

  class FormBuilder < SimpleForm::FormBuilder

    def inputs(name = nil, options = {}, &block)
      label = name ? I18n.t(name, scope: 'simple_form.titles.locomotive') : ''

      html = template.content_tag(:legend, template.content_tag(:span, label))
      html += template.capture(&block)

      options[:class] ||= 'inputs'

      template.content_tag(:fieldset, html, options)
    end

    def actions(options = {}, &block)
      options[:class] ||= 'text-right'
      template.content_tag(:div, options, &block)
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
