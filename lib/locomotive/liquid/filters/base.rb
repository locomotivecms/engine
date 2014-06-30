module Locomotive
  module Liquid
    module Filters
      module Base

        protected

        # Convert an array of properties ('key:value') into a hash
        # Ex: ['width:50', 'height:100'] => { width: '50', height: '100' }
        def args_to_options(*args)
          options = {}
          args.flatten.each do |a|
            if (a =~ /^(.*):(.*)$/)
              options[$1.to_sym] = $2
            end
          end
          options
        end

        # Write options (Hash) into a string according to the following pattern:
        # <key1>="<value1>", <key2>="<value2", ...etc
        def inline_options(options = {})
          return '' if options.empty?
          (options.stringify_keys.sort.to_a.collect { |a, b| "#{a}=\"#{b}\"" }).join(' ') << ' '
        end

        # Get the url to be used in html tags such as image_tag, flash_tag, ...etc
        # input: url (String) OR asset drop
        def get_url_from_asset(input)
          input.respond_to?(:url) ? input.url : input
        end

        def asset_url(path)
          # keep the query string safe
          path.gsub!(/(\?+.+)$/, '')
          query_string = $1

          # build the url of the theme asset based on the site and without loading
          # the whole theme asset from database
          _url = ThemeAssetUploader.url_for(@context.registers[:site], path)

          # get a timestamp only the source url does not include a query string
          timestamp = query_string.blank? ? @context.registers[:theme_assets_checksum][path] : nil

          # prefix by a asset host if given
          url = @context.registers[:asset_host].compute(_url, timestamp)

          query_string ? "#{url}#{query_string}" : url
        end

        def absolute_url(url)
          url.starts_with?('/') ? url : "/#{url}"
        end

      end

      ::Liquid::Template.register_filter(Base)

    end
  end
end