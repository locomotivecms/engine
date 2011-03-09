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

    # FIXME (Did): allows to pass attributes to the I18n translation key
    def inline_hints_for(method, options) #:nodoc:
      options[:hint] = localized_string(method, options[:hint], :hint, options[:hint_options] || {})
      return if options[:hint].blank? or options[:hint].kind_of? Hash
      hint_class = options[:hint_class] || default_hint_class
      template.content_tag(:p, Formtastic::Util.html_safe(options[:hint]), :class => hint_class)
    end

    def model_name
      @object.present? ? (@object.class.model_name || @object.class.name) : @object_name.to_s.classify
    end

    def normalize_model_name(name)
      if name =~ /(.+)\[(.+)\]/
        [$1, $2]
      else
        [name.split('/')].flatten
      end
    end

    # FIXME (Did): why the hell should all the strings be escaped ?
    def localized_string(key, value, type, options = {}) #:nodoc:
      key = value if value.is_a?(::Symbol)

      escaping = options.delete(:escaping) || false

      if value.is_a?(::String)
        escaping ? escape_html_entities(value) : value
      else
        use_i18n = value.nil? ? i18n_lookups_by_default : (value != false)

        if use_i18n
          model_name, nested_model_name  = normalize_model_name(self.model_name.underscore)
          action_name = template.params[:action].to_s rescue ''
          attribute_name = key.to_s

          defaults = ::Formtastic::I18n::SCOPES.reject do |i18n_scope|
            nested_model_name.nil? && i18n_scope.match(/nested_model/)
          end.collect do |i18n_scope|
            i18n_path = i18n_scope.dup
            i18n_path.gsub!('%{action}', action_name)
            i18n_path.gsub!('%{model}', model_name)
            i18n_path.gsub!('%{nested_model}', nested_model_name) unless nested_model_name.nil?
            i18n_path.gsub!('%{attribute}', attribute_name)
            i18n_path.gsub!('..', '.')
            i18n_path.to_sym
          end
          defaults << ''

          defaults.uniq!

          default_key = defaults.shift
          i18n_value = ::Formtastic::I18n.t(default_key,
            options.merge(:default => defaults, :scope => type.to_s.pluralize.to_sym))
          if i18n_value.blank? && type == :label
            # This is effectively what Rails label helper does for i18n lookup
            options[:scope] = [:helpers, type]
            options[:default] = defaults
            i18n_value = ::I18n.t(default_key, options)
          end
          if i18n_value.is_a?(::String)
            i18n_value = escaping ? escape_html_entities(i18n_value) : i18n_value
          end
          i18n_value.blank? ? nil : i18n_value
        end
      end
    end

  end
end