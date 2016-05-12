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

        MAX_WIDTH = [180, 157, 134].freeze # starts at depth 2

        extend Forwardable

        def_delegators :page, :_id, :parent, :title, :index_or_not_found?, :published?, :templatized?, :translated?, :redirect?, :response_type, :depth

        def fold_state
          controller.send(:cookies)["node-#{_id}"] != 'unfolded' ? 'folded' : 'unfolded'
        end

        def nodes
          children.map do |(child, children)|
            self.class.new(child, children, controller)
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

        def text_inline_style(inc = 0)
          if width = max_width(inc)
            "max-width: #{width}px;"
          else
            ''
          end
        end

        def deeper_text_inline_style
          text_inline_style(1)
        end

        def draggable
          draggable? ? 'draggable' : ''
        end

        def draggable?
          !index_or_not_found? && (templatized? || !templatized_parent?)
        end

        def templatized_parent?
          parent.templatized?
        end

        def templatized_children?
          !templatized_page.nil?
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

        def max_width(inc = 0)
          depth >= 2 ? MAX_WIDTH[depth - 2 + inc] : nil
        end

        alias :to_param :_id

      end

    end
  end
end
