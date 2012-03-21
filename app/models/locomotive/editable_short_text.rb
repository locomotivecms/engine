module Locomotive
  class EditableShortText < EditableElement

    ## fields ##
    field :content,         :localize => true
    field :default_content, :type => Boolean, :localize => true, :default => true

    ## methods ##

    def content=(value)
      self.add_current_locale
      self.default_content = false unless self.new_record?
      super
    end

    def default_content?
      !!self.default_content
    end

    def copy_attributes_from(el)
      super(el)

      self.attributes['content']          = el.content_translations || {}
      self.attributes['default_content']  = el.default_content_translations
    end

    def as_json(options = {})
      Locomotive::EditableShortTextPresenter.new(self).as_json
    end

    protected

    def propagate_content
      if self.content_changed?
        operations  = {
          '$set' => {
            "editable_elements.$.content.#{::Mongoid::Fields::I18n.locale}"         => self.content,
            "editable_elements.$.default_content.#{::Mongoid::Fields::I18n.locale}" => false,
          }
        }

        self.page.collection.update self._selector, operations, :multi => true
      end
      true
    end

  end
end