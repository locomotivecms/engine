module Locomotive
  class ImageInput < ::SimpleForm::Inputs::StringInput

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
      #{browse_button_html}
    </span>
  </label>
</div>
      EOF
    end

    def file_input
      @builder.text_field(attribute_name)
    end

    def image_html
      url = resized_file_url || default_url
      template.image_tag(url)
    end

    def browse_button_html
      label, url = text(:browse), template.content_assets_path(template.current_site)
      <<-EOF
      <a class="file-browse" href="#{url}">#{label}</a>
      EOF
    end

    def actions
      <<-EOF
      <i class="fa fa-trash" data-action="delete" style="#{'display: none;' unless file?}"></i>
      <i class="fa fa-undo" data-action="undo" style="display: none;"></i>
      <span class="spinner" style="display: none;">
        <i class="fa fa-circle-o-notch fa-spin" ></i>
      </span>
      EOF
    end

    def resize_format
      options[:resize] || '96x96#'
    end

    def filename_html
      if file?
        template.link_to(File.basename(file_url), file_url, target: 'blank')
      else
        text(:none)
      end
    end

    def file?
      self.object.send(:"#{attribute_name}").present?
    end

    def file_url
      self.object.send(attribute_name.to_sym)
    end

    def resized_file_url
      if file?
        Locomotive::Dragonfly.resize_url file_url, resize_format
      end
    end

    def default_url
      options[:default_url] || template.asset_path('locomotive/blank.png')
    end

    def file_wrapper_options
      {
        resize:         resize_format,
        persisted:      file?,
        url:            resized_file_url,
        default_url:    default_url,
        no_file_label:  text(:none)
      }.map { |k, value| "data-#{k.to_s.dasherize}=\"#{value}\"" }.join(' ')
    end

    def text(name)
      I18n.t(name, scope: 'locomotive.inputs.file')
    end

  end
end
