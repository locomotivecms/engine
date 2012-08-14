require File.join(File.dirname(__FILE__), 'content_types.rb')

module Locomotive
  module Liquid
    module Drops
      class Tag < Base
        
        delegate :name, :to => '_source'
        
          
        def before_method(meth)
          type = @context.registers[:site].content_types.where(:slug => meth.to_s).first
          TaggedContentProxyCollection.new(_source, type)
        end
      end
      
       class TaggedContentProxyCollection < Locomotive::Liquid::Drops::ContentTypeProxyCollection

        def initialize(tag, content_type)
          @tag = tag
          super(content_type)
        end

        protected

        def collection
          @collection ||= @tag.get_relation_collection(@content_type._id)
        end

      end
      
    end
  end
end
