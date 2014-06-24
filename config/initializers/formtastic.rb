require 'formtastic'
require 'formtastic-bootstrap'

Formtastic::FormBuilder.i18n_lookups_by_default = true
Formtastic::FormBuilder.configure :escape_html_entities_in_hints_and_labels, false

Formtastic::Helpers::FormHelper.builder = FormtasticBootstrap::FormBuilder
