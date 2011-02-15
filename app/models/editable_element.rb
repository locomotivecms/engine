class EditableElement

    include Mongoid::Document

    ## fields ##
    field :slug
    field :block
    field :default_content
    field :hint
    field :disabled,    :type => Boolean, :default => false
    field :from_parent, :type => Boolean, :default => false
    field :inheritable, :type => Boolean, :default => true

    ## associations ##
    embedded_in :page, :inverse_of => :editable_elements

    ## validations ##
    validates_presence_of :slug

    ## methods ##

end