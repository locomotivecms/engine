module Locomotive
  class EditableShortTextPresenter < EditableElementPresenter

    delegate :content, :to => :source

    def included_methods
      super + %w(content)
    end

  end
end