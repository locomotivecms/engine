module Admin
  class ContentsController < BaseController

    sections 'contents'

    before_filter :set_content_type

    respond_to :json, :only => :update

    def index
      @contents = @content_type.list_or_group_contents
    end

    def create
      create! { edit_admin_content_url(@content_type.slug, @content.id) }
    end

    def update
      update! { edit_admin_content_url(@content_type.slug, @content.id) }
    end

    def sort
      @content_type.sort_contents!(params[:order])

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

  end
end
