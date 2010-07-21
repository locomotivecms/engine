module Locomotive
  module Render
   
    extend ActiveSupport::Concern
   
    module InstanceMethods
      
      protected
      
      def render_locomotive_page
        @page = locomotive_page
        
        redirect_to application_root_url and return if @page.nil?
        
        output = @page.render(locomotive_context)
        
        prepare_and_set_response(output)
      end
            
      def locomotive_page
        path = request.fullpath.clone
        path.gsub!(/\.[a-zA-Z][a-zA-Z0-9]{2,}$/, '')
        path.gsub!(/^\//, '')
        path = 'index' if path.blank?
        
        if path != 'index'
          dirname = File.dirname(path).gsub(/^\.$/, '') # also look for templatized page path
          path = [path, File.join(dirname, 'content_type_template').gsub(/^\//, '')]
        end
        
        if page = current_site.pages.any_in(:fullpath => [*path]).first
          if not page.published? and current_admin.nil?
            page = nil
          else
            if page.templatized?
              @content_instance = page.content_type.contents.where(:_slug => File.basename(path.first)).first
              
              if @content_instance.nil? || (!@content_instance.visible? && current_admin.nil?) # content instance not found or not visible
                page = nil
              end
            end
          end
        end

        page || current_site.pages.not_found.published.first
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
        
        if @page.templatized? # add instance from content type
          assigns['content_instance'] = @content_instance
          assigns[@page.content_type.slug.singularize] = @content_instance # just here to help to write readable liquid code
        end
        
        registers = { :controller => self, :site => current_site, :page => @page }
          
        ::Liquid::Context.new(assigns, registers)
      end
      
      def prepare_and_set_response(output)
        response.headers['Content-Type'] = 'text/html; charset=utf-8'

        if @page.with_cache?
          fresh_when :etag => @page, :last_modified => @page.updated_at.utc, :public => true
          
          if @page.cache_strategy != 'simple' # varnish
            response.cache_control[:max_age] = @page.cache_strategy
          end
        end
          
        render :text => output, :layout => false, :status => :ok
      end      
      
    end
    
  end
end