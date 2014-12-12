# Use this setup block to configure all options available in SimpleForm.
SimpleForm.setup do |config|

  config.custom_inputs_namespaces << 'Locomotive'

  config.boolean_style = :nested

  config.wrappers :locomotive, tag: 'div', class: 'form-group input', error_class: 'has-error',
      defaults: { input_html: { class: 'default_class' } } do |b|

    b.use :label, class: 'control-label'
    b.use :hint,  wrap_with: { tag: 'span', class: 'help-block' }
    b.use :error, wrap_with: { tag: 'span', class: 'help-block has-error' }

    b.wrapper tag: :span, class: 'form-wrapper' do |c|
      c.use :html5
      c.use :min_max
      c.use :maxlength
      c.use :placeholder

      c.optional :pattern
      c.optional :readonly

      c.use :input, class: 'form-control'
    end
  end

end
