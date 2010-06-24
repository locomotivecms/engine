module Locomotive
  module Liquid
    module Drops
      class Contents < ::Liquid::Drop
    
        def initialize(site)
          @site = site
        end
  
        def before_method(meth)
          type = @site.content_types.where(:slug => meth.to_s).first
          ProxyCollection.new(@site, type)
        end
  
      end
  
      class ProxyCollection < ::Liquid::Drop
    
        def initialize(site, content_type)
          @site = site
          @content_type = content_type
          @collection = nil
        end
    
        def first
          content = @content_type.ordered_contents(@context['with_scope']).first
        end
    
        def last
          content = @content_type.ordered_contents(@context['with_scope']).last
        end
    
        def each(&block)
          @collection ||= @content_type.ordered_contents(@context['with_scope'])
          @collection.each(&block)
        end
    
        def paginate(options = {})
          @collection ||= @content_type.ordered_contents(@context['with_scope']).paginate(options)
          {
            :collection       => @collection,
            :current_page     => @collection.current_page,
            :previous_page    => @collection.previous_page,
            :next_page        => @collection.next_page,
            :total_entries    => @collection.total_entries,
            :total_pages      => @collection.total_pages,
            :per_page         => @collection.per_page
          }
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
      end
    end    
  end
end