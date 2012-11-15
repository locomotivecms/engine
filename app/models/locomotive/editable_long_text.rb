module Locomotive
  class EditableLongText < EditableShortText

    ## methods ##

    def to_presenter
      Locomotive::EditableLongTextPresenter.new(self)
    end

  end
end
