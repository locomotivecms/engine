module Locomotive
  class EditableFilePresenter < EditableElementPresenter

    ## properties ##

    with_options only_getter: true do |presenter|
      presenter.property  :content, description: 'The default url if no uploaded file'
      presenter.property  :url, description: 'Alias for content'
      presenter.property  :filename
    end

    with_options only_setter: true do |presenter|
      presenter.property    :source, description: 'A file (multipart)'
      presenter.property    :source_url
    end

    ## other getters / setters ##

    def filename
      self.content ? File.basename(self.content) : nil
    end

    def url
      self.content
    end

    def source=(value)
      self.__source.source = value
    end

    def source_url=(url)
      self.__source.remote_source_url = url
    end

  end
end
