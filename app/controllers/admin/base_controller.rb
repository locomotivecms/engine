module Admin
  class BaseController < ::ApplicationController
  
    include Locomotive::Routing::SiteDispatcher
  
    layout 'admin'
  
    before_filter :authenticate_account!
      
    before_filter :require_site
    
    before_filter :validate_site_membership
  
    before_filter :set_locale
  
    helper_method :sections
  
    protected
  
    def flash_success!(options = {})
      msg = translate_flash_msg(:successful)
      (options.has_key?(:now) && options[:now] ? flash.now : flash)[:success] = msg
    end

    def flash_error!(options = { :now => true })
      msg = translate_flash_msg(:failed)
      (options.has_key?(:now) && options[:now] ? flash.now : flash)[:error] = msg
    end
  
    def translate_flash_msg(kind)
      t("#{kind.to_s}_#{action_name}", :scope => [:admin, controller_name.underscore.gsub('/', '.'), :messages])
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
      I18n.locale = current_account.locale
    end
  
  end
end