module Locomotive
  class EditableFile < EditableElement

    ## behaviours ##
    mount_uploader 'source', EditableFileUploader

    replace_field 'source', ::String, true

    ## fields ##
    field :default_source_url, :localize => true

    ## callbacks ##
    after_save :propagate_content

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

    def default_content?
      !self.source? && self.default_source_url.present?
    end

    def copy_attributes(attributes)
      unless self.default_content?
        attributes.delete(:default_source_url)
      end

      super(attributes)
    end

    def copy_attributes_from(el)
      super(el)

      if el.source_translations.nil?
        self.attributes['default_source_url'] = el.attributes['default_source_url'] || {}
      else
        el.source_translations.keys.each do |locale|
          ::Mongoid::Fields::I18n.with_locale(locale) do
            self.default_source_url = el.source? ? el.source.url : el.default_source_url
          end
        end
      end
    end

    def set_default_content_from(el)
      super(el)

      locale = ::Mongoid::Fields::I18n.locale.to_s

      if self.attributes['default_source_url'][locale].nil?
        self.default_source_url = el.default_source_url
      end
    end

    def remove_source=(value)
      self.source_will_change! # notify the page to run the callbacks for that element
      self.default_source_url = nil
      super
    end

    def as_json(options = {})
      Locomotive::EditableFilePresenter.new(self).as_json
    end

    protected

    def propagate_content
      if self.source_changed?
        operations  = {
          '$set' => {
            "editable_elements.$.default_source_url.#{::Mongoid::Fields::I18n.locale}" => self.source.url
          }
        }

        self.page.collection.update self._selector, operations, :multi => true
      end
    end

  end
end