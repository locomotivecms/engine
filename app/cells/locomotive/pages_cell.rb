module Locomotive
  class PagesCell < Cell::Rails

    include ::Locomotive::Engine.routes.url_helpers

    delegate :cookies, to: :parent_controller

    helper_method :fold_state

    def show(args)
      @current_site = args[:site]
      @pages        = service.build_tree

      render
    end

    def show_page(page, children)
      @page           = page
      @children       = children
      @with_children  = !children.blank?

      if @with_children
        @templatized_page = @children.find { |(child, _)| child.templatized? }.try(:first)
        @content_type     = @templatized_page.try(:content_type_with_main_attributes)
      end

      render
    end

    def fold_state(page)
      # folded    => children hidden
      # unfolded  => children visible
      cookies["folder-#{page._id}"] != 'folded' ? 'unfolded' : 'folded'
    end

    protected

    def service
      @service ||= Locomotive::PagesService.new(@current_site)
    end

  end
end