module Locomotive
  class EditableSelectPresenter < EditableElementPresenter

    delegate :content, :selector_options, :to => :source

    def included_methods
      super + %w(content selector_options)
    end

  end
end
