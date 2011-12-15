module Locomotive
  module Liquid
    module Drops
      class Contents < ::Liquid::Drop

        def before_method(meth)
          type = @context.registers[:site].content_types.where(:slug => meth.to_s).first
          ProxyCollection.new(type)
        end

      end

      class ProxyCollection < ::Liquid::Drop

        def initialize(content_type)
          @content_type = content_type
          @collection = nil
        end

        def first
          self.collection.first
        end

        def last
          self.collection.last
        end

        def each(&block)
          self.collection.each(&block)
        end

        def each_with_index(&block)
          self.collection.each_with_index(&block)
        end

        def size
          self.collection.size
        end

        alias :length :size

        def empty?
          self.collection.empty?
        end

        def any?
          self.collection.any?
        end

        def api
          { 'create' => @context.registers[:controller].send('admin_api_contents_url', @content_type.slug) }
        end

        def before_method(meth)
          klass = @content_type.contents.klass # delegate to the proxy class

          if (meth.to_s =~ /^group_by_.+$/) == 0
            klass.send(meth, :ordered_contents)
          else
            klass.send(meth)
          end
        end

        protected

        def paginate(options = {})
          @collection = Kaminari.paginate_array(self.collection).page(options[:page]).per(options[:per_page])
        end

        def collection
          @collection ||= @content_type.ordered_contents(@context['with_scope'])
        end
      end

    end
  end
end
