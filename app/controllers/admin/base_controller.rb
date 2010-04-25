class Admin::BaseController < ::ApplicationController
  
  include Locomotive::Routing::SiteDispatcher
  
  layout 'admin'
  
  before_filter :authenticate_account!
  
  before_filter :require_site
  
  helper_method :sections
  
  protected
  
  def flash_success!
    flash[:success] = translate_flash_msg(:successful)
  end

  def flash_error!
    flash[:error] = translate_flash_msg(:failed)
  end
  
  def translate_flash_msg(kind)
    t("#{kind.to_s}_#{action_name}", :scope => [:admin, controller_name.underscore.gsub('/', '.'), :messages])
  end
  
  def self.sections(main, sub = nil)
    write_inheritable_attribute(:sections, { :main => main, :sub => sub })
  end
  
  def sections(key = nil)
    if !key.nil? && key.to_sym == :sub
      self.class.read_inheritable_attribute(:sections)[:sub] || self.controller_name.dasherize
    else      
      self.class.read_inheritable_attribute(:sections)[:main]
    end
  end
  
end