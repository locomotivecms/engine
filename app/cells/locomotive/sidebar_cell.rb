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

    ## Pages ##

    def show_pages(site)
      @current_site ||= site
      @pages        = pages_service.build_tree

      render view: :show_pages
    end

    def show_page(page, children)
      @page           = page
      @children       = children
      @fold_state     = cookies["folder-#{page._id}"] != 'folded' ? 'unfolded' : 'folded'
      @with_children  = !children.blank?

      if @with_children
        @templatized_page = @children.find { |(child, _)| child.templatized? }.try(:first)
        @content_type     = @templatized_page.try(:content_type_with_main_attributes)
      end

      render
    end

    protected

    def pages_service
      @service ||= Locomotive::PagesService.new(@current_site)
    end

  end
end