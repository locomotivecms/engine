class PagePart

  include Mongoid::Document

  ## fields ##
  field :name
  field :slug
  field :value
  field :disabled, :type => Boolean, :default => false
  field :value

  ## associations ##
  embedded_in :page, :inverse_of => :parts

  ## validations ##
  validates_presence_of :name, :slug

  ## named scopes ##
  scope :enabled, where(:disabled => false)

  ## methods ##

  def template
    "{% capture content_for_#{self.slug} %}#{self.value}{% endcapture %}"
  end

  def self.build_body_part(body_content = nil)
    self.new({
      :name => I18n.t('attributes.defaults.page_parts.name'),
      :value => body_content || I18n.t('attributes.defaults.pages.other.body'),
      :slug => 'layout'
    })
  end

end
