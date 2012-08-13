module Locomotive
  module Liquid
    module Drops
      class Tags < ::Liquid::Drop

        def available_tags
          CustomFields::Types::TagSet::Tag.available_tags.collect{ |tag| tag.name}
        end
        



        def before_method(meth)
          tag = CustomFields::Types::TagSet::Tag.find_tag_by_slug(meth)
          Locomotive::Liquid::Drops::Tag.new(tag)
        end

      
      end
    end
  end
end