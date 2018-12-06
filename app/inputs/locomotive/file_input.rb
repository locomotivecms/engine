module Locomotive
  class FileInput < ::SimpleForm::Inputs::FileInput

    extend Forwardable

    def_delegators :template, :link_to, :content_tag

    include Locomotive::SimpleForm::BootstrapHelpers

    def input(wrapper_options = nil)
      row_wrapping(data: { persisted: persisted_file?, persisted_file: persisted_file?, resize_format: options[:resize_format] }) do
        file_html + buttons_html
      end
    end

    def file_html
      col_wrapping :file, 8 do
        no_file_html +
        new_file_html +
        filename_or_image +
        @builder.file_field(attribute_name, input_html_options) +
        @builder.hidden_field(:"remove_#{attribute_name}", class: 'remove', value: '0') +
        @builder.hidden_field(:"remote_#{attribute_name}_url", class: 'remote-url', value: '') +
        hidden_fields
      end
    end

    def buttons_html
      col_wrapping :buttons, 4 do
        button_html(:choose, options[:select_content_asset]) +
        button_html(:change, options[:select_content_asset]) +
        button_html(:cancel, false) +
        template.link_to(trash_icon, '#', class: "delete #{hidden_css(:delete)}")
      end
    end

    def button_html(name, dropdown = true)
      if dropdown
        content_tag(:div,
          content_tag(:button,
            (text(name) + ' ' + content_tag(:span, '', class: 'caret')).html_safe,
            class: 'btn btn-primary btn-sm dropdown-toggle', data: { toggle: 'dropdown', aria_expanded: false }) +
          content_tag(:ul,
            content_tag(:li, content_tag(:a, text(:select_local_file), href: '#', class: "local-file #{name}")) +
            content_tag(:li, content_tag(:a, text(:select_content_asset), href: template.content_assets_path(template.current_site), class: 'content-assets')),
            class: 'dropdown-menu dropdown-menu-right', role: 'menu'),
          class: "btn-group #{name} #{hidden_css(name)}")
      else
        template.link_to(text(name), '#', class: "#{name} btn btn-primary btn-sm #{hidden_css(name)}")
      end
    end

    def trash_icon
      template.content_tag(:i, '', class: 'far fa-trash-alt')
    end

    def filename_or_image
      if object.persisted? && persisted_file?
        css = "current-file #{persisted_file.image? ? 'image' : ''}"
        template.content_tag :span, (image_html + filename_html).html_safe, class: css
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
      if object.persisted? && persisted_file.image?
        url = Locomotive::Dragonfly.resize_url persisted_file.url, '60x60#'
        template.image_tag(url)
      else
        ''
      end
    end

    def hidden_fields
      (options[:hidden_fields] || []).map do |name|
        @builder.hidden_field(name)
      end.join.html_safe
    end

    def filename_html
      template.link_to(File.basename(persisted_file.to_s), persisted_file.url)
    end

    def persisted_file?
      self.object.send(:"#{attribute_name}?")
    end

    def persisted_file
      self.object.send(attribute_name.to_sym)
    end

    def hidden_css(name)
      displayed = case name
      when :choose, :no_file then !object.persisted? || !persisted_file?
      when :change, :delete then object.persisted? && persisted_file?
      else false
      end

      displayed ? '' : 'hide'
    end

    def text(name)
      I18n.t(name, scope: 'locomotive.inputs.file')
    end

  end
end
