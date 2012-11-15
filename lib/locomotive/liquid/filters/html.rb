module Locomotive
  module Liquid
    module Filters
      module Html

        # Returns a link tag that browsers and news readers can use to auto-detect an RSS or ATOM feed.
        # input: url of the feed
        # example:
        #   {{ '/foo/bar' | auto_discovery_link_tag: 'rel:alternate', 'type:application/atom+xml', 'title:A title' }}
        def auto_discovery_link_tag(input, *args)
          options = args_to_options(args)

          rel   = options[:rel] || 'alternate'
          type  = options[:type] || Mime::Type.lookup_by_extension('rss').to_s
          title = options[:title] || 'RSS'

          %{<link rel="#{rel}" type="#{type}" title="#{title}" href="#{input}">}
        end

        # Write the url of a theme stylesheet
        # input: name of the css file
        def stylesheet_url(input)
          return '' if input.nil?

          unless input =~ /^(\/|https?:)/
            input = asset_url("stylesheets/#{input}")
          end

          input = "#{input}.css" unless input.ends_with?('.css')

          input
        end

        # Write the link tag of a theme stylesheet
        # input: url of the css file
        def stylesheet_tag(input, media = 'screen')
          return '' if input.nil?

          input = stylesheet_url(input)

          %{<link href="#{input}" media="#{media}" rel="stylesheet" type="text/css">}
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
        # example: 'about/myphoto.jpg' | theme_image # <img src="images/about/myphoto.jpg">
        def theme_image_tag(input, *args)
          image_options = inline_options(args_to_options(args))

          "<img src=\"#{theme_image_url(input)}\" #{image_options}>"
        end

        # Write an image tag
        # input: url of the image OR asset drop
        def image_tag(input, *args)
          image_options = inline_options(args_to_options(args))

          "<img src=\"#{get_url_from_asset(input)}\" #{image_options}>"
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
              <param name="movie" value="#{path}">
              <embed src="#{path}" #{embed_options}>
              </embed>
            </object>
          }.gsub(/ >/, '>').strip
        end

      end

      ::Liquid::Template.register_filter(Html)

    end
  end
end
