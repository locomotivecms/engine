module Locomotive
  module Liquid
    module Filters
      module Html

        # Write the link to a stylesheet resource
        # input: url of the css file
        def stylesheet_tag(input)
          return '' if input.nil?
          input = "#{input}.css" unless input.ends_with?('.css')
          %{<link href="#{input}" media="screen" rel="stylesheet" type="text/css" />}
        end

        # Write the link to javascript resource
        # input: url of the javascript file
        def javascript_tag(input)
          return '' if input.nil?
          input = "#{input}.js" unless input.ends_with?('.js')
           %{<script src="#{input}" type="text/javascript"></script>}
        end


        # Write an image tag
        # input: url of the image OR asset drop
        def image_tag(input, *args)
          image_options = inline_options(args_to_options(args))
          "<img src=\"#{File.join('/', get_path_from_asset(input))}\" #{image_options}/>"
        end

        # Embed a flash movie into a page
        # input: url of the flash movie OR asset drop
        # width: width (in pixel or in %) of the embedded movie
        # height: height (in pixel or in %) of the embedded movie
        def flash_tag(input, *args)
          path = get_path_from_asset(input)
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

          previous_link = (if paginate['previous'].blank?
            "<span class=\"disabled prev_page\">#{I18n.t('pagination.previous')}</span>"
          else
            "<a href=\"#{paginate['previous']['url']}\" class=\"prev_page\">#{I18n.t('pagination.previous')}</a>"
          end)

          links = ""
          paginate['parts'].each do |part|
            links << (if part['is_link']
              "<a href=\"#{part['url']}\">#{part['title']}</a>"
            elsif part['hellip_break']
              "<span class=\"gap\">#{part['title']}</span>"
            else
              "<span class=\"current\">#{part['title']}</span>"
            end)
          end

          next_link = (if paginate['next'].blank?
            "<span class=\"disabled next_page\">#{I18n.t('pagination.next')}</span>"
          else
            "<a href=\"#{paginate['next']['url']}\" class=\"next_page\">#{I18n.t('pagination.next')}</a>"
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
          (options.stringify_keys.to_a.collect { |a, b| "#{a}=\"#{b}\"" }).join(' ') << ' '
        end

        # Get the path to be used in html tags such as image_tag, flash_tag, ...etc
        # input: url (String) OR asset drop
        def get_path_from_asset(input)
          input.respond_to?(:url) ? input.url : input
        end
      end

      ::Liquid::Template.register_filter(Html)

    end
  end
end
