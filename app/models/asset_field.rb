class AssetField
  include Mongoid::Document
  include Mongoid::Timestamps
  
  ## fields ##
  field :label, :type => String
  field :_alias, :type => String # need it for instance in: > asset.description (description being a custom field)
  field :_name, :type => String
  field :kind, :type => String
  field :position, :type => Integer, :default => 0
    
  ## associations ##
  embedded_in :collection, :class_name => 'AssetCollection', :inverse_of => :asset_fields
  
  ## callbacks ##
  before_save :set_alias
  # before_create :add_to_list_bottom => FIXME _index does the trick actually
  # before_save :set_unique_name!
  
  ## validations ##
  validates_presence_of :label, :kind
  
  ## methods ##
  
  def field_type
    case self.kind
      when 'String', 'Text', 'Email' then String
      else
        self.kind.constantize
    end
  end
  
  def apply(object, association_name)
    puts "applying...#{self._name} / #{self._alias}"
    object.class.send(:set_field, self._name, { :type => self.field_type })
    object.class_eval <<-EOF
      alias :#{self._alias} :#{self._name}
    EOF
  end
  
  protected
  
  # def add_to_list_bottom
  #   self.position = (self.siblings.map(&:position).max || 0) + 1
  # end
  
  def set_unique_name!
    self._name = "custom_field_#{self.increment_counter!}"
  end
    
  def set_alias
    return if self.label.blank? && self._alias.blank?
    puts "set_alias !!!"
    self._alias ||= self.label.clone
    self._alias.slugify!(:downcase => true, :underscore => true)
  end
  
  def increment_counter!
    next_value = self._parent.send(:"#{self.association_name}_counter") + 1
    self._parent.send(:"#{self.association_name}_counter=", next_value)
    next_value
  end
  
  def siblings
    self._parent.associations[self.association_name]
  end
end