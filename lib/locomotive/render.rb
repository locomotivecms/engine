module Locomotive
  module Render
   
    extend ActiveSupport::Concern
   
    module InstanceMethods
      
      protected
      
      def render_locomotive_page
        @page = locomotive_page
        
        redirect_to application_root_url and return if @page.nil?
        
        output = @page.render(locomotive_context)
        
        prepare_and_set_response(output, @page.cache_expires_in || 0)
      end
            
      def locomotive_page
        path = request.fullpath.clone
        path.gsub!(/\.[a-zA-Z][a-zA-Z0-9]{2,}$/, '')
        path.gsub!(/^\//, '')
        path = 'index' if path.blank?
        
        if page = current_site.pages.where(:fullpath => path).first
          if not page.published? and current_admin.nil?
            page = nil
          end
        end

        page || current_site.pages.not_found.first
      end
      
      def locomotive_context
        assigns = {
          'site'              => current_site,
          'page'              => @page,
          'asset_collections' => Locomotive::Liquid::Drops::AssetCollections.new(current_site),
          'stylesheets'       => Locomotive::Liquid::Drops::Stylesheets.new(current_site),
          'javascripts'       => Locomotive::Liquid::Drops::Javascripts.new(current_site),
          'contents'          => Locomotive::Liquid::Drops::Contents.new(current_site),
          'current_page'      => self.params[:page]
        }
        
        registers = { :controller => self, :site => current_site, :page => @page }
          
        ::Liquid::Context.new(assigns, registers)
      end
      
      def prepare_and_set_response(output, cache_expiration = 0)
        response.headers['Cache-Control'] = "public, max-age=#{cache_expiration}" if cache_expiration > 0
        response.headers['Content-Type'] = 'text/html; charset=utf-8'
        render :text => output, :layout => false, :status => :ok
      end      
      
    end
    
  end
end