module Locomotive
  class SimpleImageInput < ImageInput

    def file_input
      @builder.file_field(attribute_name, input_html_options.merge(accept: 'image/*')) +
      @builder.hidden_field(:"remove_#{attribute_name}", class: 'remove', value: '0') +
      @builder.hidden_field(:"remote_#{attribute_name}_url", class: 'remote-url', value: '')
    end

    def browse_button_html
      <<-EOF
      <span class="file-browse">#{text(:browse)}</span>
      EOF
    end

    def file
      self.object.send(attribute_name.to_sym)
    end

    def file_url
      file.url
    end

  end
end
