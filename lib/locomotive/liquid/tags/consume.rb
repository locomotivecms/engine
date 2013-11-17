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

        Syntax = /(#{::Liquid::VariableSignature}+)\s*from\s*(#{::Liquid::QuotedString}|#{::Liquid::VariableSignature}+)/

        def initialize(tag_name, markup, tokens, context)
          if markup =~ Syntax
            @target = $1

            self.prepare_url($2)
            self.prepare_options(markup)
          else
            raise ::Liquid::SyntaxError.new("Syntax Error in 'consume' - Valid syntax: consume <var> from \"<url>\" [username: value, password: value]")
          end

          @local_cache_key = self.hash

          super
        end

        def render(context)
          if instance_variable_defined? :@variable_name
            @url = context[@variable_name]
          end
          render_all_and_cache_it(context)
        end

        protected

        def prepare_url(token)
          if token.match(::Liquid::QuotedString)
            @url = token.gsub(/['"]/, '')
          elsif token.match(::Liquid::VariableSignature)
            @variable_name = token
          else
            raise ::Liquid::SyntaxError.new("Syntax Error in 'consume' - Valid syntax: consume <var> from \"<url>\" [username: value, password: value]")
          end
        end

        def prepare_options(markup)
          @options = {}
          markup.scan(::Liquid::TagAttributes) do |key, value|
            @options[key] = value if key != 'http'
          end
          @options['timeout'] = @options['timeout'].to_f if @options['timeout']
          @expires_in = (@options.delete('expires_in') || 0).to_i
        end

        def page_fragment_cache_key(url)
          Digest::SHA1.hexdigest(@target.to_s + url)
        end

        def cached_response
          @@local_cache ||= {}
          @@local_cache[@local_cache_key]
        end

        def cached_response=(response)
          @@local_cache ||= {}
          @@local_cache[@local_cache_key] = response
        end

        def render_all_and_cache_it(context)
          Rails.cache.fetch(page_fragment_cache_key(@url), expires_in: @expires_in, force: @expires_in == 0) do
            self.render_all_without_cache(context)
          end
        end

        def render_all_without_cache(context)
          context.stack do
            begin
              context.scopes.last[@target.to_s] = Locomotive::Httparty::Webservice.consume(@url, @options.symbolize_keys)
              self.cached_response = context.scopes.last[@target.to_s]
            rescue Timeout::Error
              context.scopes.last[@target.to_s] = self.cached_response
            end

            render_all(@nodelist, context)
          end
        end

      end

      ::Liquid::Template.register_tag('consume', Consume)
    end
  end
end
