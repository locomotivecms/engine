class ContentInstance  
  include Mongoid::Document
  include Mongoid::Timestamps
  
  ## fields (dynamic fields) ##
  field :position, :type => Integer, :default => 0
  
  ## validations ##
  validate :require_highlighted_field
  
  ## associations ##
  embedded_in :content_type, :inverse_of => :contents
  
  ## methods ##
  
  protected
  
  def require_highlighted_field
    _alias = self.content_type.highlighted_field._alias.to_sym
    if self.send(_alias).blank?
      self.errors.add(_alias, :blank)
    end
  end
  
end