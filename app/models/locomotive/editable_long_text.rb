module Locomotive
  class EditableLongText < EditableShortText

    def as_json(options = {})
      Locomotive::EditableLongTextPresenter.new(self).as_json
    end

  end
end