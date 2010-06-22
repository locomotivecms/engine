module Admin
  class SnippetsController < BaseController
  
    sections 'settings'
  
    def index
      @snippets = current_site.snippets.order_by([[:name, :asc]])
    end
  
    def new
      @snippet = current_site.snippets.build
    end
  
    def edit
      @snippet = current_site.snippets.find(params[:id])
    end
  
    def create
      @snippet = current_site.snippets.build(params[:snippet])

      if @snippet.save
        flash_success!
        redirect_to edit_admin_snippet_url(@snippet)
      else
        flash_error!
        render :action => 'new'
      end
    end
  
    def update
      @snippet = current_site.snippets.find(params[:id])
      
      if @snippet.update_attributes(params[:snippet])
        flash_success!
        redirect_to edit_admin_snippet_url(@snippet)
      else
        flash_error!
        render :action => "edit"
      end
    end
  
    def destroy
      @snippet = current_site.snippets.find(params[:id])

      begin
        @snippet.destroy
        flash_success!
      rescue Exception => e
        flash[:error] = e.to_s
      end

      redirect_to admin_snippets_url
    end
  
  end
end