module Locomotive
  module Liquid
    module Tags
      module SEO

        class Base < ::Liquid::Tag

          def render(context)
            %{
              #{self.render_title(context)}
              #{self.render_metadata(context)}
            }
          end

          protected

          def render_title(context)
            title = self.value_for(:seo_title, context)
            title = context.registers[:site].name if title.blank?

            %{
              <title>#{title}</title>
            }
          end

          def render_metadata(context)
            %{
              <meta name="description" content="#{self.value_for(:meta_description, context)}">
              <meta name="keywords" content="#{self.value_for(:meta_keywords, context)}">
            }
          end

          # Removes whitespace and quote charactets from the input
          def sanitized_string(string)
            string ? string.strip.gsub(/"/, '') : ''
          end

          def value_for(attribute, context)
            object = self.metadata_object(context)
            value = object.try(attribute.to_sym).blank? ? context.registers[:site].send(attribute.to_sym) : object.send(attribute.to_sym)
            self.sanitized_string(value)
          end

          def metadata_object(context)
            context['content_entry'] || context['page']
          end
        end

        class Title < Base

          def render(context)
            self.render_title(context)
          end

        end

        class Metadata < Base

          def render(context)
            self.render_metadata(context)
          end

        end

      end

      ::Liquid::Template.register_tag('seo', SEO::Base)
      ::Liquid::Template.register_tag('seo_title', SEO::Title)
      ::Liquid::Template.register_tag('seo_metadata', SEO::Metadata)
    end
  end
end