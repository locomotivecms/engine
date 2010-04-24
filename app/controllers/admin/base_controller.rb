class Admin::BaseController < ::ApplicationController
  
  include Locomotive::Routing::SiteDispatcher
  
  layout 'admin'
  
  before_filter :authenticate_account!
  
  before_filter :require_site
  
  helper_method :sections
  
  protected
  
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