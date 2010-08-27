class EditableElement

    include Mongoid::Document

    ## fields ##
    field :slug
    field :block
    field :content
    field :default_content
    field :hint
    field :disabled, :type => Boolean, :default => false
    field :from_parent, :type => Boolean, :default => false

    ## associations ##
    embedded_in :page, :inverse_of => :editable_elements

    ## validations ##
    validates_presence_of :slug

    ## methods ##

    def content
      self.read_attribute(:content).blank? ? self.default_content : self.read_attribute(:content)
    end

end