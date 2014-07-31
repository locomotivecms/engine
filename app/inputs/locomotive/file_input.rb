module Locomotive
  class FileInput < Formtastic::Inputs::FileInput

    include FormtasticBootstrap::Inputs::Base
    # include FormtasticBootstrap::Inputs::Base::Stringish

    # include Formtastic::Inputs::Base

    def to_html
      bootstrap_wrapping do
        file_wrapper_html
        # builder.file_field(method, input_html_options)
      end
    end

    def file_wrapper_html
      row_wrapping do
        file_html + buttons_html
      end
    end

    def file_html
      col_wrapping :file do
        builder.file_field(method, input_html_options)
      end
    end

    def buttons_html
      col_wrapping :buttons do
        template.link_to 'change', '#', class: 'btn btn-primary btn-sm'
      end
    end

    def row_wrapping(&block)
      template.content_tag(:div,
        template.capture(&block).html_safe,
        class: 'row')
    end

    def col_wrapping(css, &block)
      template.content_tag(:div,
        template.capture(&block).html_safe,
        class: "col-md-6 #{css}"
      )
    end

    def no_file_html

    end


    # def input_wrapping(&block)
    #   template.content_tag(:li,
    #     [template.capture(&block), file_wrapper_html, error_html, hint_html].join("\n").html_safe,
    #     wrapper_html_options
    #   )
    # end

    # def file_wrapper_html
    #   prefix = builder.custom_namespace.present? ? "#{builder.custom_namespace}_" : ''

    #   template_id = "#{prefix}#{method}_file_input"

    #   template.content_tag(:script,
    #     %(
    #       {{#if url}}
    #       #{with_file_html}
    #       {{else}}
    #       #{without_file_html}
    #       {{/if}}).html_safe,
    #     type: 'text/html', id: template_id)
    # end

    # def with_file_html
    #   cancel_message = I18n.t('locomotive.shared.form.cancel')

    #   html =  template.link_to '{{filename}}', '{{url}}', target: '_blank'
    #   html += builder.file_field(method, input_html_options.merge(style: 'display: none'))
    #   html += template.link_to I18n.t('locomotive.shared.form.change_file'), '#', class: 'change', :'data-alt-label' => cancel_message
    #   html += template.link_to I18n.t('locomotive.shared.form.delete_file'), '#', class: 'delete', :'data-alt-label' => cancel_message
    #   html += builder.hidden_field "remove_#{method}", class: 'remove-flag'
    # end

    # def without_file_html
    #   builder.file_field(method, input_html_options).html_safe
    # end

  end
end