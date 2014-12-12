require 'formtastic'

Formtastic::FormBuilder.i18n_lookups_by_default = true
Formtastic::FormBuilder.configure :escape_html_entities_in_hints_and_labels, false

# Monkeypatch formtastic-bootstrap

module FormtasticBootstrap

  class FormBuilder < Formtastic::FormBuilder

    configure :default_inline_error_class, 'error-inline'
    configure :default_block_error_class,  'error-block'
    configure :default_inline_hint_class,  'help-inline'
    configure :default_block_hint_class,   'help-block'

    def self.default_error_class
      self.default_inline_error_class
    end

    def self.default_error_class=(error_class)
      self.default_inline_error_class = error_class
      self.default_block_error_class = error_class
    end

    def self.default_hint_class
      self.default_inline_hint_class
    end

    def self.default_hint_class=(hint_class)
      self.default_inline_hint_class = hint_class
      self.default_block_hint_class = hint_class
    end

    include FormtasticBootstrap::Helpers::InputHelper # Revisit
    include FormtasticBootstrap::Helpers::InputsHelper
    include FormtasticBootstrap::Helpers::ErrorsHelper
    include FormtasticBootstrap::Helpers::ActionHelper
    include FormtasticBootstrap::Helpers::ActionsHelper
    # include Formtastic::Helpers::ErrorsHelper

  end

end

module FormtasticBootstrap
  module Inputs
    module Base
      module Wrapping
        def bootstrap_wrapping(&block)
          form_group_wrapping do
            label_html <<
            hint_html(:inline) <<
            error_html(:inline) <<
            form_wrapper_html(&block)
          end
        end

        def form_wrapper_html(&block)
          template.content_tag(:span, class: 'form-wrapper') do
            input_content(&block)
          end
        end
      end
    end
  end
end

Formtastic::Helpers::FormHelper.builder = FormtasticBootstrap::FormBuilder
