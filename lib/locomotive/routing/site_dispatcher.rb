module Locomotive
  
  module Routing
  
    module SiteDispatcher
    
      def self.included(base)
        base.class_eval do
          include Locomotive::Routing::SiteDispatcher::InstanceMethods
        
          before_filter :fetch_site
          
          helper_method :current_site
        end
      end

      module InstanceMethods
        
        protected
        
        def fetch_site
          @site = Site.match_domain(request.host).first
        end
      
        def current_site
          @site ||= fetch_site
        end
      
        def require_site
          redirect_to application_root_url and return false if current_site.nil?
        end
        
        def application_root_url
          root_url(:host => Locomotive.config.default_domain, :port => request.port)
        end
        
      end
    
    end
  
  end
  
end