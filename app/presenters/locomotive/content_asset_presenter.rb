module Locomotive
  class ContentAssetPresenter < BasePresenter

    delegate :content_type, :width, :height, :vignette_url, :to => :source

    def full_filename
      self.source.source_filename
    end

    def filename
      truncate(self.source.source_filename, :length => 22)
    end

    def short_name
      truncate(self.source.name, :length => 15)
    end

    def extname
      truncate(self.source.extname, :length => 3)
    end

    def content_type_text
      value = self.source.content_type.to_s == 'other' ? self.extname : self.source.content_type
      value.blank? ? '?' : value
    end

    def url
      self.source.source.url
    end

    def included_methods
      super + %w(full_filename filename short_name extname content_type content_type_text url vignette_url width height)
    end

  end
end