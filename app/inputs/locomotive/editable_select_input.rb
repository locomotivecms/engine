module Locomotive
  class EditableSelectInput < ::SimpleForm::Inputs::CollectionSelectInput

    include Locomotive::SimpleForm::HeaderLink

    def link(wrapper_options)
      _header_link(:manage_collection, :select_input)
    end

  end
end
