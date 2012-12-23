module Locomotive
  class ContentAssetPresenter < BasePresenter

    ## properties ##

    properties :content_type, :width, :height

    with_options only_getter: true do |presenter|
      presenter.properties :filename, :full_filename, :short_name, :extname, :raw_size
      presenter.properties :vignette_url, :url, :content_type_text
    end

    property :source, only_setter: true

    ## custom getters / setters ##

    def full_filename
      self.__source.source_filename
    end

    def filename
      truncate(self.__source.source_filename, length: 22)
    end

    def short_name
      truncate(self.__source.name, length: 15)
    end

    def extname
      truncate(self.__source.extname, length: 3)
    end

    def content_type_text
      value = self.__source.content_type.to_s == 'other' ? self.extname : self.__source.content_type
      value.blank? ? '?' : value
    end

    def raw_size
      self.__source.size
    end

    def url
      self.__source.source.url
    end

  end
end
