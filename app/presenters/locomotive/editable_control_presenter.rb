module Locomotive
  class EditableControlPresenter < EditableElementPresenter

    delegate :content, :to => :source

    def options
      self.source.options.map do |option|
        option['selected'] = option['value'] == self.source.content
        option
      end
    end

    def included_methods
      super + %w(content options)
    end

  end
end