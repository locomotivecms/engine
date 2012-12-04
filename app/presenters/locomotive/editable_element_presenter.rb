module Locomotive
  class EditableElementPresenter < BasePresenter

    ## properties ##

    properties :slug, :block, :hint, :priority, :disabled, :from_parent, :allow_nil => true

    with_options :only_getter => true do |presenter|
      presenter.properties :label, :type, :block_name
    end

    ## other getters / setters ##

    def label
      self.labelize(self.slug)
    end

    def type
      self.source._type.to_s.demodulize
    end

    def block_name
      if self.source.block
        self.labelize(self.source.block.split('/').last)
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

