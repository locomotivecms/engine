module CustomFields
  module Types
    module Category
        
      extend ActiveSupport::Concern
      
      included do
        embeds_many :category_items, :class_name => 'CustomFields::Types::Category::Item'
        
        validates_associated :category_items
        
        accepts_nested_attributes_for :category_items, :allow_destroy => true
      end
      
      module InstanceMethods
        
        def ordered_category_items
          self.category_items.sort { |a, b| (a.position || 0) <=> (b.position || 0) }
        end
        
        def apply_category_type(klass)
          klass.cattr_accessor :"#{self.safe_alias}_items"
          
          klass.send("#{self.safe_alias}_items=", self.ordered_category_items)
          
          klass.class_eval <<-EOF
            def self.#{self.safe_alias}_names
              self.#{self.safe_alias}_items.collect(&:name)
            end
            
            def self.group_by_#{self.safe_alias}
              groups = (if self.embedded?
                self._parent.send(self.association_name).all
              else
                self.all
              end).to_a.group_by(&:#{self._name})
              
              self.#{self.safe_alias}_items.collect do |category|
                {
                  :name   => category.name,
                  :items  => groups[category._id] || []
                }.with_indifferent_access
              end
            end
            
            def #{self.safe_alias}=(name)
              category_id = self.class.#{self.safe_alias}_items.find { |item| item.name == name }._id rescue name
              write_attribute(:#{self._name}, category_id)
            end
            
            def #{self.safe_alias}
              category_id = read_attribute(:#{self._name})
              self.class.#{self.safe_alias}_items.find { |item| item._id == category_id }.name rescue category_id
            end
          EOF
        end
        
      end
      
      class Item

        include Mongoid::Document

        field :name
        field :position, :type => Integer, :default => 0

        embedded_in :custom_field, :inverse_of => :category_items
        
        validates_presence_of :name
      end      
    end
  end
end