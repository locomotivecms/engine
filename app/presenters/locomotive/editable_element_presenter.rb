module Locomotive
  class EditableElementPresenter < BasePresenter

    delegate :slug, :block, :default_content, :default_attribute, :hint, :priority, :disabled, :assignable, :from_parent, :to => :source

    def label
      self.slug.humanize
    end

    def type
      self.source._type.to_s.demodulize
    end

    def block_name
      if self.source.block
        self.source.block.gsub('\'', '').humanize
      else
        I18n.t('locomotive.pages.form.default_block')
      end
    end

    def included_methods
      super + %w(type label slug block_name block default_content default_attribute hint priority disabled assignable from_parent)
    end

  end
end

