module Admin
  class ContentsController < BaseController

    sections 'contents'

    before_filter :set_content_type

    respond_to :json, :only => [:update, :sort]

    skip_load_and_authorize_resource

    before_filter :authorize_content

    helper_method :breadcrumb_root, :breadcrumb_url, :back_url

    def index
      @contents = @content_type.list_or_group_contents
    end

    def new
      new! { @content.attributes = params[:content] }
    end

    def create
      create! { after_create_or_update_url }
    end

    def edit
      edit! { @content.attributes = params[:content] }
    end

    def update
      update! { after_create_or_update_url }
    end

    def sort
      @content_type.sort_contents!(params[:children])

      respond_with(@content_type, :location => admin_contents_url(@content_type.slug))
    end

    def destroy
      destroy! { admin_contents_url(@content_type.slug) }
    end

    protected

    def set_content_type
      @content_type ||= current_site.content_types.where(:slug => params[:slug]).first
    end

    def begin_of_association_chain
      set_content_type
    end

    def after_create_or_update_url
      if params[:breadcrumb_alias].blank?
        edit_admin_content_url(@content_type.slug, @content.id)
      else
        self.breadcrumb_url
      end
    end

    def authorize_content
      authorize! params[:action].to_sym, ContentInstance
    end

    def breadcrumb_root
      return nil if params[:breadcrumb_alias].blank?

      @breadcrumb_root ||= resource.send(params[:breadcrumb_alias].to_sym)
    end

    def breadcrumb_url
      edit_admin_content_url(self.breadcrumb_root._parent.slug, self.breadcrumb_root)
    end

    def back_url
      self.breadcrumb_root ? self.breadcrumb_url : admin_contents_url(@content_type.slug)
    end

  end
end
