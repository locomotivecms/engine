module Locomotive
  module Liquid
    module Filters
      module Misc

        def modulo(word, index, modulo)
          (index.to_i + 1) % modulo == 0 ? word : ''
        end

        def first(input)
          input.first
        end

        def last(input)
          input.last
        end

        def default(input, value)
          input.blank? ? value : input
        end

        # Render the navigation for a paginated collection
        def default_pagination(paginate, *args)
          return '' if paginate['parts'].empty?

          options = args_to_options(args)

          previous_label  = options[:previous_label] || I18n.t('pagination.previous')
          next_label      = options[:next_label] || I18n.t('pagination.next')

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

      end

      ::Liquid::Template.register_filter(Misc)

    end
  end
end
