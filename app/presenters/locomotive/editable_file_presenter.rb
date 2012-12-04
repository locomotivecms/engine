module Locomotive
  class EditableFilePresenter < EditableElementPresenter

    ## properties ##

    property    :content
    properties  :filename, :url,      :only_getter => true
    properties  :source, :source_url, :only_setter => true

    ## other getters / setters ##

    def filename
      File.basename(self.content)
    end

    def url
      self.content
    end

    def source=(value)
      self.source.source = value
    end

    def source_url=(url)
      self.source.remote_source_url = url
    end

  end
end
