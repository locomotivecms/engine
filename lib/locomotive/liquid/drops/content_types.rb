module Locomotive
  module Liquid
    module Drops
      class ContentTypes < ::Liquid::Drop

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

        def count
          @count ||= self.collection.count
        end

        alias :size   :count
        alias :length :count

        def empty?
          self.collection.empty?
        end

        def any?
          self.collection.any?
        end

        def public_submission_url
          @context.registers[:controller].main_app.locomotive_entry_submissions_url(@content_type.slug)
        end

        def before_method(meth)
          klass = @content_type.entries.klass # delegate to the proxy class

          if (meth.to_s =~ /^group_by_.+$/) == 0
            klass.send(meth, :ordered_entries)
          else
            Rails.logger.warn "[Liquid template] trying to call #{meth} on a content_type object"
            # klass.send(meth)
          end
        end

        protected

        def paginate(options = {})
          @collection.page(options[:page]).per(options[:per_page])
        end

        def collection
          @collection ||= @content_type.ordered_entries(@context['with_scope'])
        end
      end

    end
  end
end
