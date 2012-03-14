module Locomotive
  class EditableSelect < EditableElement

    after_save :update_pages

    # we use no i18n in here
    # this type of Element should be used to
    # provide a selection with fixed values for Authors/Designers
    field :content
    field :options

    # the selection options to be used directly with handlebars 
    # {{#each options}}<option value="{{value}}"{{selected}}>{{text}}</option>{{/list}}
    def selector_options
      self.options.split(/\s*\,\s*/).collect do |o| 
        first, last = *o.split(/\s*=\s*/)
        last ||= first
        {
          :value => first,
          :text => last,
          :selected => [first,last].include?(self.content) ? 'selected' : ''
        }
      end
    end

    def as_json(options = {})
      Locomotive::EditableSelectPresenter.new(self).as_json
    end

    # update all pages that are embedding this selection
    def update_pages
      if self.options_changed? && self.page && self.page.site
        self.page.site.pages.where('editable_elements.slug' => self.slug, 'editable_elements.block' => self.block).each do |p|
          p.editable_elements.where(:block => self.block, :slug => self.slug).first.set( :options, self.options ) unless p == self.page
        end 
      end
    end

  end
end

