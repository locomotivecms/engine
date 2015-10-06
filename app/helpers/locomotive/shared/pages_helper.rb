module Locomotive
  module Shared
    module PagesHelper

      def preview_page_path(page)
        _path = params[:preview_path] || current_site.localized_page_fullpath(page, current_content_locale)
        _path = 'index' if _path.blank?

        _path += response_type_name(page)

        truncate('/' + _path, length: 50)
      end

      def response_type_name(page)
        if page.default_response_type?
          ''
        else
          '.' + (MIME::Types[page.response_type.to_s].first.try(:preferred_extension) || 'html')
        end
      end

      def render_pages
        tree  = build_page_tree
        nodes = tree.map { |page, children| Node.new(page, children, controller) }

        render 'locomotive/shared/sidebar/pages', nodes: nodes, root: tree.first.first
      end

      def build_page_tree
        @page_tree ||= Locomotive::PageTreeService.new(current_site).build_tree
      end

      class Node < Struct.new(:page, :children, :controller)

        extend Forwardable

        def_delegators :page, :_id, :title, :index_or_not_found?, :published?, :templatized?, :translated?, :redirect?, :response_type

        def fold_state
          controller.send(:cookies)["node-#{_id}"] != 'unfolded' ? 'folded' : 'unfolded'
        end

        def nodes
          children.map { |(child, children)| self.class.new(child, children, controller) }
        end

        def icon
          if templatized?
            'fa-gear'
          elsif redirect?
            'fa-link'
          else
            response_type_icon
          end
        end

        def response_type_icon
          case response_type
          when 'application/rss+xml'          then 'fa-rss'
          when 'application/json', 'text/xml' then 'fa-file-code-o'
          else
            'fa-file-text-o fa-flip-horizontal'
          end
        end

        def children?
          !children.blank?
        end

        def class_names
          base = ['page']
          base << (children? ? 'node' : 'leaf')
          base << (published? ? 'published' : 'unpublished')
          base << (index_or_not_found? ? 'fixed' : '') if children?
          base.join(' ')
        end

        def draggable
          !index_or_not_found? && !templatized? ? 'draggable' : ''
        end

        def templatized_page
          return @templatized_page unless @templatized_page.nil?

          @templatized_page = (if children?
            children.find { |(child, _)| child.templatized? }.try(:first)
          end)
        end

        def content_type
          return @content_type unless @content_type.nil?

          @content_type = (if templatized_page
            templatized_page.try(:content_type_with_main_attributes)
          end)
        end

        alias :to_param :_id

      end

    end
  end
end
