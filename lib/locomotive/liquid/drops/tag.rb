require File.join(File.dirname(__FILE__), 'content_types.rb')

module Locomotive
  module Liquid
    module Drops
      class Tag < Base
        
        delegate :name, :to => '_source'
        
          
        def before_method(meth)
          type = @context.registers[:site].content_types.where(:slug => meth.to_s).first
          TaggedContent.new(_source, type)
        end
      end
      
       class TaggedContentProxyCollection < Locomotive::Liquid::Drops::ContentTypeProxyCollection

        def initialize(tag, content_type)
          @tag = tag
          super(content_type)
        end

        protected

        def collection
          @collection ||= @tag.send(@content_type.slug)
        end

      end
      
    end
  end
end
