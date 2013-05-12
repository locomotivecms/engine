module Locomotive
  class ThemeAssetPresenter < BasePresenter

    ## properties ##

    properties  :content_type, :folder, :checksum
    property    :plain_text,    allow_nil: false, description: 'Only returned after an update'

    with_options only_setter: true do |presenter|
      presenter.properties :plain_text_name, :plain_text_type, :performing_plain_text, :source
    end

    with_options only_getter: true do |presenter|
      presenter.properties :local_path, :url, :size, :raw_size, :dimensions, :can_be_deleted
    end

    ## other getters / setters ##

    def local_path
      self.__source.local_path(true)
    end

    def url
      self.__source.source.url
    end

    def size
      number_to_human_size(self.__source.size)
    end

    def raw_size
      self.__source.size
    end

    def dimensions
      self.__source.image? ? "#{self.__source.width}px x #{self.__source.height}px" : nil
    end

    def updated_at
      I18n.l(self.__source.updated_at, format: :short)
    end

    def can_be_deleted
      self.__ability.try(:can?, :destroy, self.__source)
    end

    def plain_text
      plain_text? ? self.__source.plain_text : nil
    end

    ## methods ##

    protected

    def plain_text?
      # FIXME: self.__options contains all the options passed by the responder
      self.__options[:template] == 'update' && self.__source.errors.empty? && self.__source.stylesheet_or_javascript?
    end

  end
end
