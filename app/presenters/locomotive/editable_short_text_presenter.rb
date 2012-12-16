module Locomotive
  class EditableShortTextPresenter < EditableElementPresenter

    ## properties ##

    properties :content, :default_content

    ## callbacks ##

    set_callback :set_attributes, :after, :set_default_content

    ## other getters / setters ##

    def default_content=(value)
      @default_content = value
    end

    ## methods ##

    protected

    def set_default_content
      # if the default content was not explicitly set, set it to false
      self.__source.default_content = @default_content.nil? ? false : @default_content
    end

  end
end
