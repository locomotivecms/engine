module Locomotive
  module Liquid
    module Tags
      class Find < ::Liquid::Tag

        Syntax = /(#{::Liquid::Expression}+)?/

        def initialize(tag_name, markup, tokens, context)
          if markup =~ Syntax
            @options = markup.scan(::Liquid::QuotedFragment)

            syntax_error! if @options.size != 2
          else
            syntax_error!
          end

          super
        end

        def render(context)
          Rails.logger.debug "\n\n =>>>>>>> #{@options.inspect} / #{context['params'].inspect}"

          permalink   = context[@options.last]
          site        = context.registers[:site]
          type        = site.content_types.where(:slug => @options.first).first
          entry       = type.klass_with_custom_fields(:entries).find_by_permalink(permalink)
          entry_name  = @options.first.singularize

          context.scopes.last['content_entry']  = entry
          context.scopes.last[entry_name]       = entry

          ''
        end

        protected

        def syntax_error!
          raise ::Liquid::SyntaxError.new("Syntax Error in 'find' - Valid syntax: find <content_type>, <permalink>")
        end

      end

      ::Liquid::Template.register_tag('find', Find)
    end
  end
end
