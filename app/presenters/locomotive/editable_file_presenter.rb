module Locomotive
  class EditableFilePresenter < EditableElementPresenter

    delegate :url, :to => :source

    def filename
      File.basename(self.source.url)
    end

    def included_methods
      super + %w(filename url)
    end

  end
end