class Snippet

  include Locomotive::Mongoid::Document

  ## fields ##
  field :name
  field :slug
  field :template

  ## associations ##
  referenced_in :site

  ## callbacks ##
  before_validation :normalize_slug
  after_save :update_templates
  after_destroy :update_templates

  # TODO: after_save callback to let pages embedding this snippet know about the changes the user has just made.

  ## validations ##
  validates_presence_of   :site, :name, :slug, :template
  validates_uniqueness_of :slug, :scope => :site_id

  ## methods ##

  protected

  def normalize_slug
    # TODO: refactor it
    self.slug = self.name.clone if self.slug.blank? && self.name.present?
    self.slug.slugify!(:without_extension => true, :downcase => true) if self.slug.present?
  end

  def update_templates
    return unless (self.site rescue nil) # not run if the site is being destroyed
    
    pages = self.site.pages.any_in(:snippet_dependencies => [self.slug]).to_a

    pages.each do |page|
      self._change_snippet_inside_template(page.template.root)

      page.send(:_serialize_template) && page.save
    end
  end

  def _change_snippet_inside_template(node)
    case node
    when Locomotive::Liquid::Tags::Snippet
      node.refresh(self) if node.slug == self.slug
    when Locomotive::Liquid::Tags::InheritedBlock
      self._change_snippet_inside_template(node.parent) if node.parent
    else
      if node.respond_to?(:nodelist)
        node.nodelist.each do |child|
          self._change_snippet_inside_template(child)
        end
      end
    end
  end


end
