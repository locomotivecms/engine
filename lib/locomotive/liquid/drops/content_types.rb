module Locomotive
  module Liquid
    module Drops
      class ContentTypes < ::Liquid::Drop

        def before_method(meth)
          type = @context.registers[:site].content_types.where(:slug => meth.to_s).first
          ContentTypeProxyCollection.new(type)
        end

      end

      class ContentTypeProxyCollection < ProxyCollection

        def initialize(content_type)
          @content_type = content_type
          @collection   = nil
        end

        def public_submission_url
          @context.registers[:controller].main_app.locomotive_entry_submissions_url(@content_type.slug)
        end

        def api
          Locomotive.log :warn, "[Liquid template] the api for content_types has been deprecated and replaced by public_submission_url instead."
          { 'create' => public_submission_url }
        end

        def before_method(meth)
          klass = @content_type.entries.klass # delegate to the proxy class

          if (meth.to_s =~ /^group_by_(.+)$/) == 0
            #is this a tags or a select?
            field = get_field_by_name($1)
            if (!field.nil? and field['type'] == "tag_set")
              klass.send(:group_by_tag, $1, @content_type.order_by_definition)
            else
              klass.send(:group_by_select_option, $1, @content_type.order_by_definition)
            end
          else
            Locomotive.log :warn, "[Liquid template] trying to call #{meth} on a content_type object"
          end
        end

        protected

        def collection
          @collection ||= @content_type.ordered_entries(@context['with_scope'])
        end
        
        
        def get_field_by_name(name)
          @content_type.entries_custom_fields.detect{|x| x.name==name}
        end
        
      end

    end
  end
end
