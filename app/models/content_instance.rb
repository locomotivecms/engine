class ContentInstance  
  include Mongoid::Document
  include Mongoid::Timestamps
  
  ## fields (dynamic fields) ##
  field :_position_in_list, :type => Integer, :default => 0
  
  ## validations ##
  validate :require_highlighted_field
  
  ## associations ##
  embedded_in :content_type, :inverse_of => :contents
  
  ## named scopes ##
  named_scope :latest_updated, :order_by => [[:updated_at, :desc]], :limit => Locomotive.config.lastest_items_nb
  
  ## methods ##
  
  protected
  
  def require_highlighted_field
    _alias = self.content_type.highlighted_field._alias.to_sym
    if self.send(_alias).blank?
      self.errors.add(_alias, :blank)
    end
  end
  
end