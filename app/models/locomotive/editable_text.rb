module Locomotive
  class EditableText < EditableElement

    ## fields ##
    field :content,         localize: true
    field :default_content, type: Boolean, localize: true, default: true
    field :format,          default: 'html'
    field :rows,            type: Integer, default: 15
    field :inline,          type: Boolean, default: false
    field :line_break,      type: Boolean, default: true # deprecated

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

    protected

    def strip_content
      self.content.strip! unless self.content.blank?
    end

  end
end
