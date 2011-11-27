# require 'formtastic'
# require 'locomotive/misc_form_builder'
# Formtastic::SemanticFormHelper.builder = Locomotive::MiscFormBuilder
# Formtastic::SemanticFormBuilder.i18n_lookups_by_default = true
#
require 'formtastic'

Formtastic::FormBuilder.configure :escape_html_entities_in_hints_and_labels, false
