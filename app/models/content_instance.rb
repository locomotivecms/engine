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
  validate :require_required_fields

  ## associations ##
  embedded_in :content_type, :inverse_of => :contents

  ## callbacks ##
  before_save :set_slug
  before_save :set_visibility
  before_create :add_to_list_bottom
  after_create :send_notifications

  ## named scopes ##
  scope :latest_updated, :order_by => :updated_at.desc, :limit => Locomotive.config.lastest_items_nb

  ## methods ##

  alias :visible? :_visible?
  alias :_permalink :_slug

  def site_id  # needed by the uploader of custom fields
    self.content_type.site_id
  end

  def highlighted_field_value
    self.send(self.content_type.highlighted_field._name)
  end

  def visible?
    self._visible || self._visible.nil?
  end

  def aliased_attributes # TODO: move it to the custom_fields gem
    hash = { :created_at => self.created_at, :updated_at => self.updated_at }

    self.custom_fields.each do |field|
      case field.kind
      when 'file' then hash[field._alias] = self.send(field._name.to_sym).url
      else
        hash[field._alias] = self.send(field._name.to_sym)
      end
    end

    hash
  end

  def errors_to_hash
    Hash.new.replace(self.errors)
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
  
  def require_required_fields
    self.custom_fields.each do |field|
      next if field.required == false or field._alias.to_s == self.highlighted_field_alias.to_s
      
      self.errors.add(field._alias, :blank) if self.send(field._alias).blank?
      
    end
  end 

  def highlighted_field_alias
    self.content_type.highlighted_field._alias.to_sym
  end

  def send_notifications
    return unless self.content_type.api_enabled? && !self.content_type.api_accounts.blank?

    accounts = self.content_type.site.accounts.to_a

    self.content_type.api_accounts.each do |account_id|
      next if account_id.blank?

      account = accounts.detect { |a| a.id.to_s == account_id.to_s }

      Admin::Notifications.new_content_instance(account, self).deliver
    end
  end

end
