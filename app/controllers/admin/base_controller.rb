module Admin
  class BaseController < InheritedResources::Base
    
    include Locomotive::Routing::SiteDispatcher
    
    layout 'admin/application'
    
    before_filter :authenticate_admin!
      
    before_filter :require_site
    
    before_filter :validate_site_membership
  
    before_filter :set_locale
  
    helper_method :sections
    
    # https://rails.lighthouseapp.com/projects/8994/tickets/1905-apphelpers-within-plugin-not-being-mixed-in
    Dir[File.dirname(__FILE__) + "/../../helpers/**/*_helper.rb"].each do |file|
      helper "admin/#{File.basename(file, '.rb').gsub(/_helper$/, '')}"
    end
        
    self.responder = Locomotive::AdminResponder # custom responder
    
    defaults :route_prefix => 'admin'
    
    respond_to :html
    
    protected
    
    def begin_of_association_chain
      current_site
    end    
  
    def self.sections(main, sub = nil)
      before_filter do |c|
        sub = sub.call(c) if sub.respond_to?(:call)
        sections = { :main => main, :sub => sub }
        c.instance_variable_set(:@admin_sections, sections)
      end
    end
  
    def sections(key = nil)
      if !key.nil? && key.to_sym == :sub
        @admin_sections[:sub] || self.controller_name.dasherize
      else      
        @admin_sections[:main]
      end      
    end
  
    def set_locale
      I18n.locale = current_admin.locale
    end
      
  end
end