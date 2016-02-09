module Locomotive
  class EditableModel < EditableElement

    def content_type
      @content_type ||= self.page.site.content_types.by_id_or_slug(self.slug).first
    end

    def label
      self.content_type.name
    end

    def content_type?
      !content_type.nil?
    end

  end
end
