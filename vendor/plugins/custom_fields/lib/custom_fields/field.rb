module CustomFields

  class Field
    include ::Mongoid::Document
    include ::Mongoid::Timestamps
    
    # types ##
    include Types::Default
    include Types::String
    include Types::Text
    include Types::Category
    include Types::Boolean
    include Types::Date
    include Types::File
  
    ## fields ##
    field :label
    field :_alias
    field :_name
    field :kind
    field :hint
    field :position, :type => Integer, :default => 0
      
    ## validations ##
    validates_presence_of :label, :kind
    validate :uniqueness_of_label
      
    ## methods ##
    
    def field_type
      self.class.field_types[self.kind.downcase.to_sym]
    end
    
    def apply(klass)
      return unless self.valid?
      
      klass.field self._name, :type => self.field_type if self.field_type
      
      apply_method_name = :"apply_#{self.kind.downcase}_type"
      
      if self.respond_to?(apply_method_name)
        self.send(apply_method_name, klass)
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