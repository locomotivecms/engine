module Locomotive
  module Liquid
    module Drops
      class ContentTypes < ::Liquid::Drop

        def before_method(meth)
          type = @context.registers[:site].content_types.where(slug: meth.to_s).first
          ContentTypeProxyCollection.new(type)
        end

      end

      class ContentTypeProxyCollection < ProxyCollection

        def initialize(content_type)
          @content_type = content_type
          @collection   = nil
        end

        def public_submission_url
          @context.registers[:controller].main_app.locomotive_entry_submissions_path(@content_type.slug)
        end

        def api
          Locomotive.log :warn, "[Liquid template] the api for content_types has been deprecated and replaced by public_submission_url instead."
          { 'create' => public_submission_url }
        end

        def before_method(meth)
          klass = @content_type.entries.klass # delegate to the proxy class

          if (meth.to_s =~ /^group_by_(.+)$/) == 0
            klass.send(:group_by_select_option, $1, @content_type.order_by_definition)
          elsif (meth.to_s =~ /^(.+)_options$/) == 0
            klass.send(:"#{$1}_options").map { |option| option['name'] }
          else
            Locomotive.log :warn, "[Liquid template] trying to call #{meth} on a content_type object"
          end
        end

        protected

        def collection
          if @context['with_scope']
            self.modify_with_scope
          end

          @collection ||= @content_type.ordered_entries(@context['with_scope']).visible
        end

        # Modify the attributes of the with_scope tag so that
        # they can be resolved by MongoDB.
        #
        def modify_with_scope
          @context['with_scope'].dup.each do |key, value|
            field = @content_type.find_entries_custom_field(key.to_s)

            next if field.nil?

            case field.type.to_sym
            when :belongs_to
              self.modify_with_scope_key(key, "#{key.to_s}_id", self.object_to_id(field, value))
            when :many_to_many
              self.modify_with_scope_key(key, "#{key.to_s.singularize}_ids", self.object_to_id(field, value))
            when :select
              option = field.select_options.detect { |option| [option.name, option._id.to_s].include?(value) }
              self.modify_with_scope_key(key, "#{key.to_s}_id", option.try(:_id))
            end
          end
        end

        # Change the value of a key of the with_scope depending of its type.
        # If the key is a Origin::Key, we only change the name.
        # If the key is a String, we replace it.
        #
        # @param [ Object ] key Either a String or a Origin::Key
        # @param [ String ] name The new name of the key
        # @param [ String ] value The new value associated to the key
        #
        def modify_with_scope_key(key, name, value)
          if key.respond_to?(:operator)
            key.instance_variable_set :@name, name
            @context['with_scope'][key] = value
          else
            @context['with_scope'].delete(key)
            @context['with_scope'][name] = value
          end
        end

        # Get the _id attribute of a object or a list of objects which
        # can include String (needed to retrieve a model
        # based on its permalink or its label field) or ContentEntry instances.
        #
        # @param [ Object ] field The custom field
        # @param [ Object ] value An object (content entry or label) or a list of objects
        #
        def object_to_id(field, value)
          if value.respond_to?(:map)
            value.map { |el| self.object_to_id(field, el) }
          elsif value.respond_to?(:_id)
            value._id
          else
            model = Locomotive::ContentType.class_name_to_content_type(field.class_name, @content_type.site)
            model.entries.or({ _slug: value }, { model.label_field_name => value }).first.try(:_id)
          end
        end

      end

    end
  end
end
