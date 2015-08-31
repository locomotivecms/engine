module Locomotive
  module PagesHelper

    def parent_pages_options
      [].tap do |list|
        build_page_tree.each do |(page, children)|
          next if page.not_found?

          add_children_to_options(page, children, list)
        end
      end
    end

    def add_children_to_options(page, children, list)
      return list if page.parent_ids.include?(@page.id) || page == @page

      offset = '- ' * (page.depth || 0) * 2

      list << ["#{offset}#{page.title}", page.id]

      if children
        children.each { |(_page, _children)| add_children_to_options(_page, _children, list) }
      end

      list
    end

    def display_page_layouts?
      ((@page.persisted? && @page.allow_layout?) || !@page.persisted?) &&
      !current_site.pages.layouts.empty?
    end

    def options_for_page_layouts
      layouts = current_site.pages.layouts.map do |_layout|
        [_layout.title, _layout._id]
      end
      [[t(:no_layout, scope: 'locomotive.pages.form'), 'parent']] + layouts
    end

    # def options_for_page_response_type
    #   [
    #     ['HTML', 'text/html'],
    #     ['RSS', 'application/rss+xml'],
    #     ['XML', 'text/xml'],
    #     ['JSON', 'application/json']
    #   ]
    # end

    def options_for_page_redirect_type
      [
        [t('.redirect_type.permanent'), 301],
        [t('.redirect_type.temporary'), 302]
      ]
    end

    # def page_response_type_to_string(page)
    #   options_for_page_response_type.detect { |t| t.last == page.response_type }.try(:first) || '&mdash;'
    # end

  end
end
