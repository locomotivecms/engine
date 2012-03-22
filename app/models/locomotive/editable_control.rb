module Locomotive
  class EditableControl < EditableElement

    ## fields ##
    field :content
    field :options, :type => Array,   :default => []

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

    def default_content?
      false
    end

    def copy_attributes_from(el)
      super(el)

      %w(content options).each do |meth|
        self.attributes[meth] = el.attributes[meth]
      end
    end

    def as_json(options = {})
      Locomotive::EditableControlPresenter.new(self).as_json
    end

    protected

    def propagate_content
      if self.content_changed?
        operations  = {
          '$set' => {
            'editable_elements.$.content' => self.content,
            'editable_elements.$.options' => self.options,
          }
        }

        self.page.collection.update self._selector, operations, :multi => true
      end
      true
    end

  end
end

