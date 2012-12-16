module Locomotive
  class EditableElementPresenter < BasePresenter

    ## properties ##

    properties :slug, :block, allow_nil: true

    with_options required: false, allow_nil: true do |presenter|
      presenter.property  :hint
      presenter.property  :priority, type: 'Integer'
    end

    with_options only_getter: true do |presenter|
      presenter.properties  :label, :type, :block_name
      presenter.properties  :from_parent, type: 'Boolean'
      presenter.property    :disabled, type: 'Boolean'
    end

    ## other getters / setters ##

    def label
      self.labelize(self.slug)
    end

    def type
      self.__source._type.to_s.demodulize
    end

    def block_name
      if self.__source.block
        self.labelize(self.__source.block.split('/').last)
      else
        I18n.t('locomotive.pages.form.default_block')
      end
    end

    ## methods ##

    protected

    def labelize(label)
      label.gsub(/[\"\']/, '').gsub('-', ' ').humanize
    end

  end
end

