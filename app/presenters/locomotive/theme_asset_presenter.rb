module Locomotive
  class ThemeAssetPresenter < BasePresenter

    delegate :content_type, :folder, :plain_text, :to => :source

    def local_path
      self.source.local_path(true)
    end

    def url
      self.source.source.url
    end

    def size
      number_to_human_size(self.source.size)
    end

    def raw_size
      self.source.size
    end

    def dimensions
      self.source.image? ? "#{self.source.width}px x #{self.source.height}px" : nil
    end

    def updated_at
      I18n.l(self.source.updated_at, :format => :short)
    end

    def can_be_deleted
      self.ability.try(:can?, :destroy, self.source)
    end

    def included_methods
      default_list = %w(content_type folder local_path url size raw_size dimensions can_be_deleted updated_at)
      default_list += %w(plain_text) if plain_text?
      super + default_list
    end

    private

    def plain_text?
      # FIXME: self.options contains all the options passed by the responder
      self.options[:template] == 'update' && self.source.errors.empty? && self.source.stylesheet_or_javascript?
    end

  end
end