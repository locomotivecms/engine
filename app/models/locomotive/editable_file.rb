module Locomotive
  class EditableFile < EditableElement

    mount_uploader :source, EditableFileUploader

    replace_field :source, ::String, true

    def content
      self.source? ? self.source.url : self.default_content
    end

    def as_json(options = {})
      Locomotive::EditableFilePresenter.new(self).as_json
    end

  end
end