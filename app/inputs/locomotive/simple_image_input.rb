module Locomotive
  class SimpleImageInput < ::SimpleForm::Inputs::FileInput

    extend Forwardable

    def_delegators :template, :link_to, :content_tag, :image_tag

    def input(wrapper_options = nil)
      <<-EOF
<div class="file-wrapper" #{file_wrapper_options}>
  <div class="file-image">
    #{image_html}
    #{actions}
  </div>
  <label class="file">
    #{file_input}
    <span class="file-custom">
      <span class="file-name">#{filename_html}</span>
      <span class="file-browse">#{text(:browse)}</span>
    </span>
  </label>
</div>
      EOF
    end

    def file_input
      @builder.file_field(attribute_name, input_html_options.merge(accept: 'image/*')) +
      @builder.hidden_field(:"remove_#{attribute_name}", class: 'remove', value: '0') +
      @builder.hidden_field(:"remote_#{attribute_name}_url", class: 'remote-url', value: '')
    end

    def image_html
      url = resized_file_url || options[:default_url]
      url ? template.image_tag(url) : ''
    end

    def actions
      <<-EOF
      <i class="fa fa-trash" data-action="delete"></i>
      <i class="fa fa-undo" data-action="undo" style="display: none;"></i>
      EOF
    end

    def resize_format
      options[:resize] || '96x96#'
    end

    def filename_html
      if file?
        template.link_to(File.basename(file.to_s), file.url, target: 'blank')
      else
        text(:none)
      end
    end

    def file?
      self.object.send(:"#{attribute_name}?")
    end

    def file
      self.object.send(attribute_name.to_sym)
    end

    def resized_file_url
      if file?
        Locomotive::Dragonfly.resize_url file.url, resize_format
      end
    end

    def file_wrapper_options
      {
        resize:         resize_format,
        persisted:      file?,
        url:            resized_file_url,
        default_url:    options[:default_url],
        no_file_label:  text(:none)
      }.map { |k, value| "data-#{k.to_s.dasherize}=\"#{value}\"" }.join(' ')
    end

    def text(name)
      I18n.t(name, scope: 'locomotive.inputs.file')
    end

  end
end
