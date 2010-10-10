class ContentInstance

  include Mongoid::Document
  include Mongoid::Timestamps

  ## extensions ##
  include CustomFields::ProxyClassEnabler

  ## fields (dynamic fields) ##
  field :_slug
  field :_position_in_list, :type => Integer, :default => 0
  field :_visible, :type => Boolean, :default => true

  ## validations ##
  validate :require_highlighted_field

  ## associations ##
  embedded_in :content_type, :inverse_of => :contents

  ## callbacks ##
  before_save :set_slug
  before_save :set_visibility
  before_create :add_to_list_bottom

  ## named scopes ##
  scope :latest_updated, :order_by => [[:updated_at, :desc]], :limit => Locomotive.config.lastest_items_nb

  ## methods ##

  alias :visible? :_visible?

  def site_id  # needed by the uploader of custom fields
    self.content_type.site_id
  end

  def visible?
    self._visible || self._visible.nil?
  end

  def to_liquid
    Locomotive::Liquid::Drops::Content.new(self)
  end

  protected

  def set_slug
    _alias = self.highlighted_field_alias
    self._slug = self.send(_alias).parameterize('_')
  end

  def set_visibility
    field = self.content_type.content_custom_fields.detect { |f| %w{visible active}.include?(f._alias) }
    self._visible = self.send(field._name) rescue true
  end

  def add_to_list_bottom
    Rails.logger.debug "add_to_list_bottom"
    self._position_in_list = self.content_type.contents.size
  end

  def require_highlighted_field
    _alias = self.highlighted_field_alias
    if self.send(_alias).blank?
      self.errors.add(_alias, :blank)
    end
  end

  def highlighted_field_value
    self.send(self.content_type.highlighted_field._name)
  end

  def highlighted_field_alias
    self.content_type.highlighted_field._alias.to_sym
  end

end
