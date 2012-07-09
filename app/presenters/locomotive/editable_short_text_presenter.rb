module Locomotive
  class EditableShortTextPresenter < EditableElementPresenter

    delegate :content, :default_content, :to => :source

    delegate :content=, :default_content=, :to => :source

    def included_methods
      super + %w(content default_content)
    end

    def included_setters
      super + %w(content default_content)
    end

  end
end
