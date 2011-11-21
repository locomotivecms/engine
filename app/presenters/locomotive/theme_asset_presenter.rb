module Locomotive
  class ThemeAssetPresenter < BasePresenter

    def local_path
      self.source.local_path(true)
    end

    def url
      self.source.source.url
    end

    def size
      number_to_human_size(self.source.size)
    end

    def updated_at
      I18n.l(self.source.updated_at, :format => :short)
    end

    def included_methods
      super + %w(local_path url size updated_at)
    end

  end
end