module Locomotive
  class EditableSelectInput < ::SimpleForm::Inputs::CollectionSelectInput

    include Locomotive::SimpleForm::HeaderLink

    def link(wrapper_options)
      _header_link(:manage_collection, :select_input)
    end

    def errors_on_attribute
      (options[:error_name] ? object.errors[options[:error_name]] : nil) || super
    end

  end
end
