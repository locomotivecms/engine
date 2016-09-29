module Locomotive
  class EditableControl < EditableElement

    ## fields ##
    field :content, localize: true
    field :default_content, type: Boolean, default: true
    field :options, type: Array, default: []

    ## methods ##

    def options=(value)
      if value.respond_to?(:split)
        value = value.split(/\s*\,\s*/).map do |option|
          first, last = *option.split(/\s*=\s*/)
          last ||= first
          { 'value' => first, 'text' => last }
        end
      end

      super(value)
    end

    def content=(value)
      return if value == self.content
      self.default_content = false unless self.new_record?
      super
    end

    def content_from_default=(content)
      if self.default_content?
        self.content = content.to_s
      end
    end

  end
end

