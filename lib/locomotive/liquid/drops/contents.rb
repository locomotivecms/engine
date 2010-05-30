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
          build_content_drop(content) unless content.nil?
        end
    
        def last
          content = @content_type.ordered_contents(@context['with_scope']).last
          build_content_drop(content) unless content.nil?
        end
    
        def each(&block)
          @collection ||= @content_type.ordered_contents(@context['with_scope'])
          to_content_drops.each(&block)
        end
    
        def to_content_drops
          @collection.map { |c| build_content_drop(c) }
        end
        
        def build_content_drop(content)
          Locomotive::Liquid::Drops::Content.new(content)
        end
    
        def paginate(options = {})
          @collection ||= @content_type.ordered_contents(@context['with_scope']).paginate(options)
          {
            :collection       => to_content_drops,
            :current_page     => @collection.current_page,
            :previous_page    => @collection.previous_page,
            :next_page        => @collection.next_page,
            :total_entries    => @collection.total_entries,
            :total_pages      => @collection.total_pages,
            :per_page         => @collection.per_page
          }
        end
        
      end
  
    end
    
  end

end