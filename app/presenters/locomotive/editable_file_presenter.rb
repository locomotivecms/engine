module Locomotive
  class EditableFilePresenter < EditableElementPresenter

    delegate :content, :to => :source

    def filename
      File.basename(self.content)
    end

    def included_methods
      super + %w(filename content url)
    end

  end
end