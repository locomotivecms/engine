module Locomotive
  class EditableControlPresenter < EditableElementPresenter

    ## properties ##

    property :content
    property :options, :only_getter => true

    ## other getters / setters ##

    def options
      self.__source.options.map do |option|
        option['selected'] = option['value'] == self.__source.content
        option
      end
    end

  end
end
