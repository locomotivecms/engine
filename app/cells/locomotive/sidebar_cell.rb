module Locomotive
  class SidebarCell < Cell::Rails

    include ::Locomotive::Engine.routes.url_helpers

    delegate :cookies, to: :parent_controller

    def show(args)
      @current_site = args[:site]
      @list         = args[:list]

      @list.map do |element|
        case element
        when Symbol, String then send(:"show_#{element}", @current_site)
        when Hash           then show_link(element)
        else ''
        end
      end.join('').html_safe
    end

    ## Links ##

    def show_link(attributes)
      @attributes = attributes

      render view: :show_link
    end

    ## Content Types ##

    def show_content_types(site)
      @list = content_type_service.list

      render view: :show_content_types
    end

    ## Pages ##

    def show_pages(site)
      @current_site ||= site
      @pages        = page_service.build_tree

      render view: :show_pages
    end

    def page(page, children)
      @page           = page
      @children       = children
      @fold_state     = cookies["node-#{page._id}"] != 'folded' ? 'unfolded' : 'folded'
      @with_children  = !children.blank?
      @fixed          = page.index_or_not_found? ? 'fixed' : ''
      @published      = page.published? ? 'published' : 'unpublished'
      @draggable      = !page.index_or_not_found? && !page.templatized? ? 'draggable' : ''

      if @with_children
        @templatized_page = @children.find { |(child, _)| child.templatized? }.try(:first)
        @content_type     = @templatized_page.try(:content_type_with_main_attributes)
      end

      @link = render view: :page_link

      render
    end

    protected

    def page_service
      @page_service ||= Locomotive::PageService.new(@current_site)
    end

    def content_type_service
      @content_type_service ||= Locomotive::ContentTypeService.new(@current_site)
    end

  end
end
