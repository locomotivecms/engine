class EditableElement

    include Mongoid::Document

    ## fields ##
    field :slug
    field :block
    field :default_content
    field :default_attribute
    field :hint
    field :priority,    :type => Integer, :default => 0
    field :disabled,    :type => Boolean, :default => false
    field :assignable,  :type => Boolean, :default => true
    field :from_parent, :type => Boolean, :default => false

    ## associations ##
    embedded_in :page, :inverse_of => :editable_elements

    ## validations ##
    validates_presence_of :slug

    ## scopes ##
    scope :by_priority, :order_by => [[:priority, :desc]]

    ## methods ##

end