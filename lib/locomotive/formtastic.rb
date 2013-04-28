module Formtastic
  module Inputs
    module Base
      module Errors
        def error_sentence_html
          error_class = options[:error_class] || builder.default_inline_error_class
          template.content_tag(:div,
            template.content_tag(:p, Formtastic::Util.html_safe(errors.to_sentence.html_safe)), class: error_class)
        end
      end
    end
  end

  # See: https://github.com/justinfrench/formtastic/issues/796
  module Helpers
    module InputHelper

      def input_class_with_const_defined(as)
        input_class_name = custom_input_class_name(as)

        # get the parent module
        module_class_name = input_class_name.deconstantize
        module_class = module_class_name.blank? ? ::Object : module_class_name.constantize

        # the input class name without the module part
        input_class_name_wo_module = input_class_name.demodulize

        if module_class.const_defined?(input_class_name_wo_module)
          input_class_name.constantize
        elsif Formtastic::Inputs.const_defined?(input_class_name)
          standard_input_class_name(as).constantize
        else
          raise Formtastic::UnknownInputError, "Unable to find input class #{input_class_name}"
        end
      end
    end
  end
end