module Locomotive
  class EditableShortText < EditableElement

    ## fields ##
    field :content, :localize => true

    ## methods ##

    def content_with_localization
      value = self.content_without_localization
      value.blank? ? self.default_content : value
    end

    alias_method_chain :content, :localization

    def as_json(options = {})
      Locomotive::EditableShortTextPresenter.new(self).as_json
    end

  end
end