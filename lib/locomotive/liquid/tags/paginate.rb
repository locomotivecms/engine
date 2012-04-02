module Locomotive

  module Liquid

      module Tags

      # Paginate a collection
      #
      # Usage:
      #
      # {% paginate contents.projects by 5 %}
      #   {% for project in paginate.collection %}
      #     {{ project.name }}
      #   {% endfor %}
      #  {% endpaginate %}
      #

      class Paginate < ::Liquid::Block

        Syntax = /(#{::Liquid::Expression}+)\s+by\s+([0-9]+)/

        def initialize(tag_name, markup, tokens, context)
          if markup =~ Syntax
            @collection_name = $1
            @per_page = $2.to_i
          else
            raise ::Liquid::SyntaxError.new("Syntax Error in 'paginate' - Valid syntax: paginate <collection> by <number>")
          end

          super
        end

        def render(context)
          context.stack do
            collection = context[@collection_name]

            raise ::Liquid::ArgumentError.new("Cannot paginate array '#{@collection_name}'. Not found.") if collection.nil?

            if collection.is_a? Array
              pagination = Kaminari.paginate_array(collection).page(context['current_page']).per(@per_page).to_liquid.stringify_keys
            else
              pagination = collection.send(:paginate, {
                :page       => context['current_page'],
                :per_page   => @per_page
              }).to_liquid.stringify_keys
            end
            page_count, current_page = pagination['total_pages'], pagination['current_page']

            path = sanitize_path(context['fullpath'])

            pagination['previous'] = link(I18n.t('pagination.previous'), current_page - 1, path) if pagination['previous_page']
            pagination['next'] = link(I18n.t('pagination.next'), current_page + 1, path) if pagination['next_page']
            pagination['parts'] = []

            hellip_break = false

            if page_count > 1
              1.upto(page_count) do |page|
                if current_page == page
                  pagination['parts'] << no_link(page)
                elsif page == 1
                  pagination['parts'] << link(page, page, path)
                elsif page == page_count - 1
                  pagination['parts'] << link(page, page, path)
                elsif page <= current_page - window_size or page >= current_page + window_size
                  next if hellip_break
                  pagination['parts'] << no_link('&hellip;')
                  hellip_break = true
                  next
                else
                  pagination['parts'] << link(page, page, path)
                end

                hellip_break = false
              end
            end

            context['paginate'] = pagination

            render_all(@nodelist, context)
          end
        end

        private

        def sanitize_path(path)
          _path = path.gsub(/page=[0-9]+&?/, '').gsub(/_pjax=true&?/, '')
          _path = _path.slice(0..-2) if _path.last == '?' || _path.last == '&'
          _path
        end

        def window_size
          3
        end

        def no_link(title)
          { 'title' => title, 'is_link' => false, 'hellip_break' => title == '&hellip;' }
        end

        def link(title, page, path)
          _path = %(#{path}#{path.include?('?') ? '&' : '?'}page=#{page})
          { 'title' => title, 'url' => _path, 'is_link' => true }
        end
      end

      ::Liquid::Template.register_tag('paginate', Paginate)
    end

  end

end
