class EditableShortText < EditableElement

  ## fields ##
  field :content

  ## methods ##

  def content
    self.read_attribute(:content).blank? ? self.default_content : self.read_attribute(:content)
  end

end