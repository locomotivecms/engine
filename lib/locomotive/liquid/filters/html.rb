module Locomotive
  module Liquid
    module Filters
      module Html

        # Write the url to a stylesheet resource
        # input: name of the css file
        def stylesheet_url(input)
          return '' if input.nil?

          unless input =~ /^(\/|https?:)/
            input = asset_url("stylesheets/#{input}")
          end

          input = "#{input}.css" unless input.ends_with?('.css')

          input
        end

        # Write the link to a stylesheet resource
        # input: url of the css file
        def stylesheet_tag(input, media = 'screen')
          return '' if input.nil?

          input = stylesheet_url(input)

          %{<link href="#{input}" media="#{media}" rel="stylesheet" type="text/css" />}
        end

        # Write the url to javascript resource
        # input: name of the javascript file
        def javascript_url(input)
          return '' if input.nil?

          unless input =~ /^(\/|https?:)/
            input = asset_url("javascripts/#{input}")
          end

          input = "#{input}.js" unless input.ends_with?('.js')

          input
        end

        # Write the link to javascript resource
        # input: url of the javascript file
        def javascript_tag(input)
          return '' if input.nil?

          input = javascript_url(input)

          %{<script src="#{input}" type="text/javascript"></script>}
        end

        def theme_image_url(input)
          return '' if input.nil?

          input = "images/#{input}" unless input.starts_with?('/')

          asset_url(input)
        end

        # Write a theme image tag
        # input: name of file including folder
        # example: 'about/myphoto.jpg' | theme_image # <img src="images/about/myphoto.jpg" />
        def theme_image_tag(input, *args)
          image_options = inline_options(args_to_options(args))

          "<img src=\"#{theme_image_url(input)}\" #{image_options}/>"
        end

        # Write an image tag
        # input: url of the image OR asset drop
        def image_tag(input, *args)
          image_options = inline_options(args_to_options(args))

          "<img src=\"#{get_url_from_asset(input)}\" #{image_options}/>"
        end

        # Embed a flash movie into a page
        # input: url of the flash movie OR asset drop
        # width: width (in pixel or in %) of the embedded movie
        # height: height (in pixel or in %) of the embedded movie
        def flash_tag(input, *args)
          path = get_url_from_asset(input)
          embed_options = inline_options(args_to_options(args))
          %{
            <object #{embed_options}>
              <param name="movie" value="#{path}" />
              <embed src="#{path}" #{embed_options}/>
              </embed>
            </object>
          }.gsub(/ >/, '>').strip
        end

        # Render the navigation for a paginated collection
        def default_pagination(paginate, *args)
          return '' if paginate['parts'].empty?

          options = args_to_options(args)

          previous_label = options[:previous_label] || I18n.t('pagination.previous')
          next_label = options[:next_label] || I18n.t('pagination.next')

          previous_link = (if paginate['previous'].blank?
            "<span class=\"disabled prev_page\">#{previous_label}</span>"
          else
            "<a href=\"#{absolute_url(paginate['previous']['url'])}\" class=\"prev_page\">#{previous_label}</a>"
          end)

          links = ""
          paginate['parts'].each do |part|
            links << (if part['is_link']
              "<a href=\"#{absolute_url(part['url'])}\">#{part['title']}</a>"
            elsif part['hellip_break']
              "<span class=\"gap\">#{part['title']}</span>"
            else
              "<span class=\"current\">#{part['title']}</span>"
            end)
          end

          next_link = (if paginate['next'].blank?
            "<span class=\"disabled next_page\">#{next_label}</span>"
          else
            "<a href=\"#{absolute_url(paginate['next']['url'])}\" class=\"next_page\">#{next_label}</a>"
          end)

          %{<div class="pagination #{options[:css]}">
              #{previous_link}
              #{links}
              #{next_link}
            </div>}
        end

        protected

        # Convert an array of properties ('key:value') into a hash
        # Ex: ['width:50', 'height:100'] => { :width => '50', :height => '100' }
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
          ThemeAssetUploader.url_for(@context.registers[:site], path)
        end

        def absolute_url(url)
          url.starts_with?('/') ? url : "/#{url}"
        end

      end

      ::Liquid::Template.register_filter(Html)

    end
  end
end
