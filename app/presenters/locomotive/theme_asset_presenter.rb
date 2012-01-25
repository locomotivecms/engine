module Locomotive
  class ThemeAssetPresenter < BasePresenter

    delegate :content_type, :folder, :to => :source

    def local_path
      self.source.local_path(true)
    end

    def url
      self.source.source.url
    end

    def size
      number_to_human_size(self.source.size)
    end

    def dimensions
      self.source.image? ? "#{self.source.width}px x #{self.source.height}px" : nil
    end

    def updated_at
      I18n.l(self.source.updated_at, :format => :short)
    end

    def included_methods
      super + %w(content_type folder local_path url size dimensions updated_at)
    end

  end
end