module CustomFields

  class Field
    include ::Mongoid::Document
    include ::Mongoid::Timestamps
    
    # types ##
    include Types::Default
    include Types::Category
  
    ## fields ##
    field :label
    field :_alias # need it for instance in: > asset.description (description being a custom field)
    field :_name
    field :kind
    field :hint
    field :position, :type => Integer, :default => 0
      
    ## validations ##
    validates_presence_of :label, :kind
    validate :uniqueness_of_label
      
    ## methods ##
    
    %w{String Text Category}.each do |kind|
      define_method "#{kind.downcase}?" do
        self.kind == kind
      end
    end
  
    def field_type
      case self.kind
        when 'String', 'Text', 'Category' then String
        else
          self.kind.constantize
      end
    end
    
    def apply(klass)
      return unless self.valid?
      
      klass.field self._name, :type => self.field_type
      
      case self.kind
      when 'Category'
        apply_category_type(klass)
      else
        apply_default_type(klass)
      end
    end
    
    def safe_alias
      self.set_alias
      self._alias 
    end
  
    protected
    
    def uniqueness_of_label
      duplicate = self.siblings.detect { |f| f.label == self.label && f._id != self._id }
      if not duplicate.nil?
        self.errors.add(:label, :taken)
      end
    end
  
    def set_unique_name!
      self._name ||= "custom_field_#{self.increment_counter!}"
    end
    
    def set_alias
      return if self.label.blank? && self._alias.blank?
      self._alias = (self._alias.blank? ? self.label : self._alias).parameterize('_').downcase
    end
  
    def increment_counter!
      next_value = (self._parent.send(:"#{self.association_name}_counter") || 0) + 1
      self._parent.send(:"#{self.association_name}_counter=", next_value)
      next_value
    end
  
    def siblings
      self._parent.send(self.association_name)
    end
  end
  
end