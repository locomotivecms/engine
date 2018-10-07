module Locomotive
  class TreeViewInput < ::SimpleForm::Inputs::Base

    include Locomotive::SimpleForm::BootstrapHelpers
    include Locomotive::SimpleForm::HeaderLink
    include Locomotive::SimpleForm::Inputs::FasterTranslate

    def input(wrapper_options)
      hidden_input + tree_view_wrapper
    end

    def hidden_input
       _template = options[:template]
      template_path = _template.respond_to?(:has_key?) ? _template[:path].to_s : _template.to_s
      template.render(template_path).html_safe
    end

    def tree_view_wrapper
      row_wrapping do
        template.content_tag :div,
          tree_view_html,
          class: tree_view_wrapper_class
      end
    end

    def tree_view_wrapper_class
      %w(col-md-12).tap do |wrapper_class|
      end.join(' ')
    end

    def tree_view_html
      template.content_tag :div, '', class: 'tree-view-div', 'data-source': options[:source_options].to_json
    end

    def link(wrapper_options)
      
    end

  end
end
