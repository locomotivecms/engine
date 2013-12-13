module Locomotive
  class Snippet

    include Locomotive::Mongoid::Document
    include Extensions::Shared::Slug

    ## fields ##
    field :name
    field :slug
    field :template, localize: true

    ## associations ##
    belongs_to :site, class_name: 'Locomotive::Site'

    ## callbacks ##
    after_save        :update_templates
    after_destroy     :update_templates

    ## validations ##
    validates_presence_of   :site, :name, :slug, :template
    validates_uniqueness_of :slug, scope: :site_id

    ## behaviours ##
    slugify_from    :name
    attr_protected  :id
    attr_accessible :name, :slug, :template

    ## methods ##

    protected

    def update_templates
      return unless (self.site rescue false) # not run if the site is being destroyed

      pages = ::I18n.with_locale(::Mongoid::Fields::I18n.locale) do
        pages = self.site.pages.any_in(snippet_dependencies: [self.slug]).to_a
      end

      pages.each do |page|
        self._change_snippet_inside_template(page.template.root)

        page.send(:_serialize_template)

        Page.without_callback(:save, :after, :update_template_descendants) do
          page.save(validate: false)
        end
      end
    end

    def _change_snippet_inside_template(node)
      case node
      when Locomotive::Liquid::Tags::Snippet
        node.refresh(self, _default_context) if node.slug == self.slug
      when Locomotive::Liquid::Tags::InheritedBlock
        _change_snippet_inside_template(node.parent) if node.parent
      end
      # Walk the children of this entry if they're available.
      if node.respond_to?(:nodelist)
        (node.nodelist || []).each do |child|
          self._change_snippet_inside_template(child)
        end
      end
    end

    def _default_context
      { site: site }
    end
  end
end