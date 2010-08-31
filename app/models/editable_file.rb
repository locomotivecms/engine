class EditableFile < EditableElement

  mount_uploader :source, EditableFileUploader

  def content
    self.source? ? self.source.url : self.default_content
  end

end