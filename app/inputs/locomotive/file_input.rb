module Locomotive
  class FileInput < SimpleForm::Inputs::FileInput

    include Locomotive::BootstrapFormHelper

    def input(wrapper_options = nil)
      row_wrapping(data: { persisted: persisted_file?, persisted_file: persisted_file? }) do
        file_html + buttons_html
      end
    end

    def file_html
      col_wrapping :file do
        no_file_html +
        new_file_html +
        filename_or_image +
        @builder.file_field(attribute_name, input_html_options) +
        @builder.hidden_field(:"remove_#{attribute_name}")
      end
    end

    def buttons_html
      col_wrapping :buttons do
        template.link_to(text(:choose), '#', class: "choose btn btn-primary btn-sm #{hidden_css(:choose)}") +
        template.link_to(text(:change), '#', class: "change btn btn-primary btn-sm #{hidden_css(:change)}") +
        template.link_to(text(:cancel), '#', class: "cancel btn btn-primary btn-sm #{hidden_css(:cancel)}") +
        template.link_to(trash_icon, '#', class: "delete #{hidden_css(:delete)}")
      end
    end

    def trash_icon
      template.content_tag(:i, '', class: 'fa fa-trash-o')
    end

    def filename_or_image
      if persisted_file?
        css = "current-file #{persisted_file.image? ? 'image' : ''}"
        template.content_tag :span, image_html + filename_html, class: css
      else
        ''
      end
    end

    def no_file_html
      template.content_tag :span, text(:none), class: "no-file #{hidden_css(:no_file)}"
    end

    def new_file_html
      template.content_tag :span, 'New file here', class: "new-file #{hidden_css(:new_file)}"
    end

    def image_html
      if persisted_file.image?
        url = Locomotive::Dragonfly.resize_url persisted_file.url, '60x60#'
        template.image_tag(url)
      else
        ''
      end
    end

    def filename_html
      template.link_to(File.basename(persisted_file.to_s), persisted_file.url)
    end

    def persisted_file?
      object.send(:"#{attribute_name}?")
    end

    def persisted_file
      self.object.send(attribute_name.to_sym)
    end

    def hidden_css(name)
      displayed = case name
      when :choose, :no_file then !object.persisted? || !persisted_file?
      when :change, :delete then persisted_file?
      else false
      end

      displayed ? '' : 'hide'
    end

    def text(name)
      I18n.t("locomotive.shared.form.file_input.#{name}")
    end

  end
end
