module Locomotive
  module Liquid
      module Tags
      # Consume web services as easy as pie directly in liquid !
      #
      # Usage:
      #
      # {% consume blog from 'http://nocoffee.tumblr.com/api/read.json?num=3' username: 'john', password: 'easy', format: 'json', expires_in: 3000 %}
      #   {% for post in blog.posts %}
      #     {{ post.title }}
      #   {% endfor %}
      # {% endconsume %}
      #
      class Consume < ::Liquid::Block

        Syntax = /(#{::Liquid::VariableSignature}+)\s*from\s*(#{::Liquid::QuotedString}+)/

        def initialize(tag_name, markup, tokens, context)
          if markup =~ Syntax
            @target = $1
            @url = $2.gsub(/['"]/, '')
            @options = {}
            markup.scan(::Liquid::TagAttributes) do |key, value|
              @options[key] = value if key != 'http'
            end
            @expires_in = (@options.delete('expires_in') || 0).to_i
            @cache_key = Digest::SHA1.hexdigest(@target)
          else
            raise ::Liquid::SyntaxError.new("Syntax Error in 'consume' - Valid syntax: consume <var> from \"<url>\" [username: value, password: value]")
          end

          super
        end

        def render(context)
          render_all_and_cache_it(context)
        end

        protected

        def render_all_and_cache_it(context)
          Rails.cache.fetch(@cache_key, :expires_in => @expires_in, :force => @expires_in == 0) do
            context.stack do
              context.scopes.last[@target.to_s] = Locomotive::Httparty::Webservice.consume(@url, @options.symbolize_keys)

              render_all(@nodelist, context)
            end
          end
        end

      end

      ::Liquid::Template.register_tag('consume', Consume)
    end
  end
end
