class MiscFormBuilder < Formtastic::SemanticFormBuilder
  
  @@all_fields_required_by_default = false
  
  def foldable_inputs(*args, &block)
    opts = args.extract_options!
    
    unfolded = !(opts[:class] || '').index('off').nil? || @object.new_record? || !@object.errors.empty?
    
    opts[:class] = (opts[:class] || '') + " inputs foldable #{'folded' unless unfolded}"
    args.push(opts)
    self.inputs(*args, &block)
  end
  
  def custom_input(name, options = {}, &block)
    default_options = { :css => '', :with_label => true, :label => nil }
    options = default_options.merge(options)
    
    html = options[:with_label] ? self.label(options[:label] || name) : ''
    html += template.capture(&block) || ''
    html += self.errors_on(name) || ''

    template.content_tag(:li, html, :class => "#{options[:css]} #{'error' unless @object.errors[name].empty?}")
  end
  
end
