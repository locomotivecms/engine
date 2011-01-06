module Locomotive
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
      html += inline_hints_for(name, options) || ''
      html += self.errors_on(name) || ''

      template.content_tag(:li, template.find_and_preserve(html), :style => "#{options[:style]}", :class => "#{options[:css]} #{'error' unless @object.errors[name].empty?}")
    end

    def inline_errors_on(method, options = nil)
      if render_inline_errors?
        errors = @object.errors[method.to_sym]
        template.content_tag(:span, [*errors].to_sentence.untaint, :class => 'inline-errors') if errors.present?
      else
        nil
      end
    end

    def model_name
      @object.present? ? (@object.class.name || @object.class.model_name) : @object_name.to_s.classify
    end

  end
end