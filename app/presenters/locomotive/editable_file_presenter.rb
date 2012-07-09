module Locomotive
  class EditableFilePresenter < EditableElementPresenter

    delegate :content, :to => :source

    def filename
      File.basename(self.content)
    end

    def url
      self.content
    end

    def source=(value)
      self.source.source = value
    end

    def included_methods
      super + %w(filename content url)
    end

    def included_setters
      super + %w(source)
    end

  end
end
