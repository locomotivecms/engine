module Locomotive
  class DocumentPickerInput < SimpleForm::Inputs::Base

    def input(wrapper_options)
      data = options[:document]

      data[:label] = label(data[:label_method])

      @builder.hidden_field(:"#{attribute_name}_id", {
        data: data
      })
    end

    private

    def label(method)
      if document = self.object.send(attribute_name.to_sym)
        document.send(:method)
      else
        nil
      end
    end

  end
end
