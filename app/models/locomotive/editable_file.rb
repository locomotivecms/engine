module Locomotive
  class EditableFile < EditableElement

    ## behaviours ##
    mount_uploader 'source', EditableFileUploader

    replace_field 'source', ::String, true

    ## fields ##
    field :default_source_url, localize: true

    ## methods ##

    # Returns the url or the path to the uploaded file
    # if it exists. Otherwise returns the default url.
    #
    # @note This method is not used for the rendering, only for the back-office
    #
    # @return [String] The url or path of the file
    #
    def content
      self.source? ? self.source.url : self.default_source_url
    end

    alias :content= :source=

    def remove_source=(value)
      self.source_will_change! # notify the page to run the callbacks for that element
      super
    end

  end
end
