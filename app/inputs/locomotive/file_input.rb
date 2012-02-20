module Locomotive
  class FileInput

    include Formtastic::Inputs::Base

    def to_html
      input_wrapping do
        label_html
      end
    end

    def input_wrapping(&block)
      template.content_tag(:li,
        [template.capture(&block), file_wrapper_html, error_html, hint_html].join("\n").html_safe,
        wrapper_html_options
      )
    end

    def file_wrapper_html
      template.content_tag(:script,
        %(
          {{#if url}}
          #{with_file_html}
          {{else}}
          #{without_file_html}
          {{/if}}).html_safe,
        :type => 'text/html', :id => "#{method}_file_input")
    end

    def with_file_html
      cancel_message = I18n.t('locomotive.shared.form.cancel')

      html =  template.link_to '{{filename}}', '{{url}}', :target => '_blank'
      html += builder.file_field(method, input_html_options.merge(:style => 'display: none'))
      html += template.link_to I18n.t('locomotive.shared.form.change_file'), '#', :class => 'change', :'data-alt-label' => cancel_message
      html += template.link_to I18n.t('locomotive.shared.form.delete_file'), '#', :class => 'delete', :'data-alt-label' => cancel_message
      html += builder.hidden_field "remove_#{method}", :class => 'remove-flag'
    end

    def without_file_html
      builder.file_field(method, input_html_options).html_safe
    end

  end
end