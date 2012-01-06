class ContentInstance

  include Mongoid::Document
  include Mongoid::Timestamps

  ## extensions ##
  include CustomFields::ProxyClassEnabler
  include Extensions::Shared::Seo

  ## fields (dynamic fields) ##
  field :_slug
  field :_position_in_list, :type => Integer, :default => 0
  field :_visible, :type => Boolean, :default => true

  ## validations ##
  validate :require_highlighted_field
  validates :_slug, :presence => true, :uniqueness => { :scope => :content_type_id }

  ## associations ##
  embedded_in :content_type, :inverse_of => :contents

  ## callbacks ##
  before_validation :set_slug
  after_save :sync_habtm
  before_save :set_visibility
  before_create :add_to_list_bottom
  after_create :send_notifications

  ## named scopes ##
  scope :latest_updated, :order_by => :updated_at.desc, :limit => Locomotive.config.lastest_items_nb

  ## methods ##

  delegate :site, :to => :content_type

  alias :visible? :_visible?
  alias :_permalink :_slug
  alias :_permalink= :_slug=

  def site_id  # needed by the uploader of custom fields
    self.content_type.site_id
  end

  def highlighted_field_value
    self.send(self.content_type.highlighted_field_name)
  end

  alias :_label :highlighted_field_value

  def visible?
    self._visible || self._visible.nil?
  end
  
  def next
    content_type.contents.where(:_position_in_list => _position_in_list + 1).first()
  end
  
  def previous
    content_type.contents.where(:_position_in_list => _position_in_list - 1).first()
  end

  def errors_to_hash
    Hash.new.replace(self.errors)
  end

  def reload_parent!
    self.class.reload_parent!
  end

  def self.reload_parent!
    self._parent = self._parent.reload
  end

  def to_liquid
    Locomotive::Liquid::Drops::Content.new(self)
  end

  protected

  # Sets the slug of the instance by using the value of the highlighted field
  # (if available). If a sibling content instance has the same permalink then a
  # unique one will be generated
  def set_slug
    self._slug = highlighted_field_value.dup if _slug.blank? && highlighted_field_value.present?

    if _slug.present?
      self._slug.permalink!
      self._slug = next_unique_slug if slug_already_taken?
    end
  end

  # Return the next available unique slug as a string
  def next_unique_slug
    slug        = _slug.gsub(/-\d*$/, '')
    last_slug   = _parent.contents.where(:_id.ne => _id, :_slug => /^#{slug}-?\d*?$/i).order_by(:_slug).last._slug
    next_number = last_slug.scan(/-(\d)$/).flatten.first.to_i + 1

    [slug, next_number].join('-')
  end

  def slug_already_taken?
    _parent.contents.where(:_id.ne => _id, :_slug => _slug).any?
  end

  # if self.content_type includes a target_field with has_many 
  # and the target.content_type has_many types of self
  # it can be seen as an habtm ('has_and_belongs_to_many') relation
  def habtm_relation_targets
    self.content_type.fields_by_kind('has_many').collect do |has_many_field|
      target_type = has_many_field.target_klass._parent
      target_type.fields_by_kind('has_many').any?{ |f| f.target_klass._parent == self.content_type } ? target_type : nil
    end.compact
  end

  # prevent recursive syncing
  def save_without_habtm_sync
    @habtm_sync = false
    self.save
  end

  # syncronise with 'has_and_belongs_to_many' targets
  def sync_habtm
    return if @habtm_sync == false
    self_slug = self.content_type.slug
    self.habtm_relation_targets.each do |target_type|
      # scan target_contents for missing references to self
      self.send(target_type.slug).each do |target_content|
        parent_reverses =  target_content.send(self_slug)
        unless parent_reverses.include?( self )
          # adding to relation
          target_content.send("#{self_slug}=", parent_reverses + [self] )
          target_content.save_without_habtm_sync
        end
      end
      # scan target_contents for orphaned references to self
      self.content_type.site.content_types.where(slug: target_type.slug).first.contents.each do |target_content|
        child_reverses = target_content.send(self_slug)
        if child_reverses.any?{ |c| c == self && !self.send("#{target_content.content_type.slug}").any?{ |t| t == target_content } }
          # removing from relation
          target_content.send("#{self_slug}=", child_reverses - [self] )
          target_content.save_without_habtm_sync
        end
      end
    end
  end


  def set_visibility
    field = self.content_type.content_custom_fields.detect { |f| %w{visible active}.include?(f._alias) }
    self._visible = self.send(field._name) rescue true
  end

  def add_to_list_bottom
    self._position_in_list = self.content_type.contents.size
  end

  def require_highlighted_field
    _alias = self.highlighted_field_alias
    if self.send(_alias).blank?
      self.errors.add(_alias, :blank)
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
