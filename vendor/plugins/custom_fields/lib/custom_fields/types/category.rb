module CustomFields
  module Types
    module Category
        
      extend ActiveSupport::Concern
      
      included do
        embeds_many :category_items, :class_name => 'CustomFields::Types::Category::Item'
      end
      
      module InstanceMethods
        
        def ordered_category_items
          self.category_items.sort { |a, b| (a.position || 0) <=> (b.position || 0) }
        end
        
        def apply_category_type(klass)
          klass.cattr_accessor :"#{self.safe_alias}_items"
          
          klass.send("#{self.safe_alias}_items=", self.category_items)
          
          klass.class_eval <<-EOF
            def self.#{self.safe_alias}_names
              #{self.safe_alias}_items.collect(&:name)
            end
            
            def #{self.safe_alias}=(name)
              category_id = self.class.#{self.safe_alias}_items.where(:name => name).first._id rescue nil
              write_attribute(:#{self._name}, category_id)
            end
            
            def #{self.safe_alias}
              category_id = read_attribute(:#{self._name})
              self.class.#{self.safe_alias}_items.find(category_id).name rescue nil
            end
          EOF
        end
        
      end
      
      class Item

        include Mongoid::Document

        field :name
        field :position, :type => Integer, :default => 0

        embedded_in :custom_field, :inverse_of => :category_items
      end      
    end
  end
end