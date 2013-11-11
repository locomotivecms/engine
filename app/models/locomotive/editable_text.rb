module Locomotive
  class EditableText < EditableElement

    ## fields ##
    field :content,         localize: true
    field :default_content, type: Boolean, localize: true, default: true
    field :format,          default: 'html'
    field :rows,            type: Integer, default: 15
    field :line_break,      type: Boolean, default: true

    ## callbacks ##
    before_save :strip_content

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

      self.copy_formatting_attributes_from(el)

      self.attributes['content']          = el.content_translations || {}
      self.attributes['default_content']  = el.default_content_translations
    end

    def copy_default_attributes_from(el)
      super(el)

      self.copy_formatting_attributes_from(el)
    end

    def copy_formatting_attributes_from(el)
      %w(format rows line_break).each do |attr|
        self.attributes[attr] = el.attributes[attr]
      end
    end

    def set_default_content_from(el)
      super(el)

      locale = ::Mongoid::Fields::I18n.locale.to_s

      if self.default_content? || self.attributes['default_content'][locale].nil?
        self.default_content = true

        self.content_will_change!

        if self.attributes['content']
          self.attributes['content'][locale] = el.content
        end
      end
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

        self.page.collection.find(self._selector).update(operations, multi: true)
      end
      true
    end

    def strip_content
      self.content.strip! unless self.content.blank?
    end

  end
end