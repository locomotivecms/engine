module Locomotive
  class ContentInstance

    include ::Mongoid::Document
    include ::Mongoid::Timestamps

    ## extensions ##
    include ::Mongoid::TargetCustomFields
    include Extensions::Shared::Seo

    ## fields (dynamic fields) ##
    field :_highlighted_field
    field :_slug
    field :_position_in_list, :type => Integer, :default => 0
    field :_visible,          :type => Boolean, :default => true

    ## validations ##
    validate              :require_highlighted_field
    # validate              :validate_uniqueness_of_slug
    validates_uniqueness_of :_slug, :scope => [:content_type_id]
    validates_presence_of   :_slug

    ## associations ##
    belongs_to  :site
    belongs_to  :content_type, :class_name => 'Locomotive::ContentType', :inverse_of => :contents
    # embedded_in :content_type, :class_name => 'Locomotive::ContentType', :inverse_of => :contents

    ## callbacks ##
    before_validation :set_slug
    before_save       :set_visibility
    before_create     :add_to_list_bottom
    after_create      :send_notifications

    ## named scopes ##
    scope :visible, :where => { :_visible => true }
    scope :latest_updated, :order_by => :updated_at.desc, :limit => Locomotive.config.lastest_items_nb

    ## methods ##

    # delegate :site, :to => :content_type

    alias :visible? :_visible?
    alias :_permalink :_slug
    alias :_permalink= :_slug=

    # def site_id  # needed by the uploader of custom fields
    #   self.content_type.site_id
    # end

    def highlighted_field_value
      self.send(self.content_type.highlighted_field_name)
    end

    alias :_label :highlighted_field_value

    def visible?
      self._visible || self._visible.nil?
    end

    def next # TODO
      # content_type.contents.where(:_position_in_list => _position_in_list + 1).first()
    end

    def previous # TODO
      # content_type.contents.where(:_position_in_list => _position_in_list - 1).first()
    end

    # def errors_to_hash # TODO
    #   Hash.new.replace(self.errors)
    # end

    # def reload_parent! # TODO
    #   self.class.reload_parent!
    # end
    #
    # def self.reload_parent! # TODO
    #   self._parent = self._parent.reload
    # end

    def to_liquid
      Locomotive::Liquid::Drops::Content.new(self)
    end

    protected

    def set_slug
      self._slug = self.highlighted_field_value.dup if self._slug.blank? && self.highlighted_field_value.present?
      self._slug.permalink! if self._slug.present?
    end

    def set_visibility
      %w(visible active).map(&:to_sym).each do |_alias|
        if self.methods.include?(_alias)
          self._visible = self.send(_alias)
          return
        end
      end
      # field = self.content_type.contents_custom_fields.detect { |f| %w{visible active}.include?(f._alias) }
      # self._visible = self.send(field._name) rescue true
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

    # def validate_uniqueness_of_slug
    #   if self._parent.contents.any? { |c| c._id != self._id && c._slug == self._slug }
    #     self.errors.add(:_slug, :taken)
    #   end
    # end

    def highlighted_field_alias
      self.content_type.highlighted_field._alias.to_sym
    end

    def send_notifications
      return unless self.content_type.api_enabled? && !self.content_type.api_accounts.blank?

      accounts = self.content_type.site.accounts.to_a

      self.content_type.api_accounts.each do |account_id|
        next if account_id.blank?

        account = accounts.detect { |a| a.id.to_s == account_id.to_s }

        Locomotive::Notifications.new_content_instance(account, self).deliver
      end
    end

  end
end
