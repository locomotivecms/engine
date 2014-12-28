module Locomotive
  class EditableSelectInput < SimpleForm::Inputs::CollectionSelectInput

    def link(wrapper_options)
      if _options = options[:manage_collection]
        label = _options[:label] || I18n.t(:edit, scope: 'locomotive.shared.form.select_input')
        url   = _options[:url]
        template.link_to(label, url)
      else
        ''
      end
    end

  end
end
