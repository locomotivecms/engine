module Locomotive

  class PageTreeService < Struct.new(:site)

    # Returns the tree of pages from the site with the most minimal amount of queries.
    # This method should only be used for read-only purpose since
    # the mongodb returns the minimal set of required attributes to build
    # the tree.
    #
    # @return [ Array ] The first array of pages (index + page not found + pages with depth == 1)
    #
    def build_tree
      pages, page_not_found = pages_with_minimun_attributes, nil

      [].tap do |tree|
        while page = pages.shift
          if page.not_found?
            # move the "page not found" (404) at the end of the array
            page_not_found = page
          elsif page.index?
            # make the index page without children
            tree << [page, nil]
          elsif !page.is_layout_or_related?
            tree << _build_tree(page, pages)
          end
        end

        tree << [page_not_found, nil]
      end
    end

    protected

    #:nodoc:
    def pages_with_minimun_attributes
      site.pages.unscoped.
        minimal_attributes.
        order_by_depth_and_position.
        to_a.tap do |pages|
          Rails.logger.debug "*** pages = #{pages.first.inspect}"
        end
    end

    #:nodoc:
    def _build_tree(current_page, pages)
      i, children = 0, []

      while !pages.empty?
        page = pages[i]

        break if page.nil? # end of the array

        if page.parent_id == current_page.id
          page = pages.delete_at(i)

          children << _build_tree(page, pages)
        else
          i += 1
        end
      end

      [current_page, children]
    end

  end
end
