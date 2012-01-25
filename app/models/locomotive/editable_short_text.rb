module Locomotive
  class EditableShortText < EditableElement

    ## fields ##
    field :content

    ## methods ##

    def content
      self.read_attribute(:content).blank? ? self.default_content : self.read_attribute(:content)
    end

    def as_json(options = {})
      Locomotive::EditableShortTextPresenter.new(self).as_json
    end

  end
end