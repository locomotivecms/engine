module Locomotive
  class EditableShortText < EditableElement

    ## fields ##
    field :content,         :localize => true
    field :default_content, :type => Boolean, :localize => true, :default => true

    ## methods ##

    def content=(value)
      return if value == self.content
      self.add_current_locale
      self.default_content = false unless self.new_record?
      super
    end

    def default_content?
      !!self.default_content
    end

    def content_from_default=(content)
      if self.default_content?
        self.content_will_change!
        self.attributes['content'] ||= {}
        self.attributes['content'][::Mongoid::Fields::I18n.locale.to_s] = content
      end
    end

    def copy_attributes_from(el)
      super(el)

      self.attributes['content']          = el.content_translations || {}
      self.attributes['default_content']  = el.default_content_translations
    end

    def set_default_content_from(el)
      super(el)

      locale = ::Mongoid::Fields::I18n.locale.to_s

      if self.default_content? || self.attributes['default_content'][locale].nil?
        self.default_content = true

        self.content_will_change!
        self.attributes['content'][locale] = el.content
      end
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