module Locomotive
  class DocumentPickerInput < ::SimpleForm::Inputs::Base

    include Locomotive::SimpleForm::BootstrapHelpers

    def input(wrapper_options)
      data = extract_data

      row_wrapping do
        (col_wrapping('field col-xs-9', 11) do
          hidden_field(data)
        end) + (col_wrapping('button col-xs-3 text-right', 1) do
          link_to_edit
        end)
      end
    end

    def hidden_field(data)
      @builder.hidden_field(:"#{attribute_name}_id", {
        class:  'form-control',
        data:   data
      })
    end

    def link_to_edit
      label     = options[:edit][:label]
      css_class = 'btn btn-primary btn-sm edit'

      if url = options[:edit][:url]
        template.content_tag(:a, label, href: url, class: css_class)
      else
        ''
      end
    end

    def extract_data
      options[:picker].tap do |data|
        data[:per_page] ||= Locomotive.config.ui[:per_page]
        data[:label]    = document_label(data[:label_method])
      end
    end

    def document_label(label_method)
      if document = self.object.send(attribute_name.to_sym)
        document.send(label_method.to_sym)
      else
        nil
      end
    end

  end
end
