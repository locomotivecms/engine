module Locomotive
  class EditableFile < EditableElement

    mount_uploader :source, EditableFileUploader, :mount_on => :source_filename

    def content
      self.source? ? self.source.url : self.default_content
    end

  end
end