require 'formtastic'
require 'formtastic-bootstrap'

Formtastic::FormBuilder.i18n_lookups_by_default = true
Formtastic::FormBuilder.configure :escape_html_entities_in_hints_and_labels, false

# Monkeypatch formtastic-bootstrap

module FormtasticBootstrap

  class FormBuilder < Formtastic::FormBuilder

    configure :default_inline_error_class, 'help-inline'
    configure :default_block_error_class,  'help-block'
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

Formtastic::Helpers::FormHelper.builder = FormtasticBootstrap::FormBuilder
