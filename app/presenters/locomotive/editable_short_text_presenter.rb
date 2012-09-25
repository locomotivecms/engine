module Locomotive
  class EditableShortTextPresenter < EditableElementPresenter

    delegate :content, :default_content, :to => :source

    delegate :content=, :to => :source

    attr_writer :default_content

    def set_default_content
      # If the default content was not explicitly set, set it to false
      if @default_content
        self.source.default_content = self.default_content
      elsif self.source.content
        self.source.default_content = false
      end
    end

    def included_methods
      super + %w(content default_content)
    end

    def included_setters
      super + %w(content default_content)
    end

    def assign_attributes(new_attributes)
      super(new_attributes)
      set_default_content
    end

  end
end
