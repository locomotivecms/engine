module Locomotive
  class ContentEntry

    include Locomotive::Mongoid::Document

    ## extensions ##
    include ::CustomFields::Target
    include Extensions::Shared::Seo

    ## fields (dynamic fields) ##
    # field :_highlighted_field
    field :_slug
    field :_position_in_list, :type => Integer, :default => 0
    field :_visible,          :type => Boolean, :default => true

    ## validations ##
    # validate  :require_highlighted_field
    validates :_slug, :presence => true, :uniqueness => { :scope => :content_type_id }

    ## associations ##
    belongs_to  :site
    belongs_to  :content_type, :class_name => 'Locomotive::ContentType', :inverse_of => :contents

    ## callbacks ##
    before_validation :set_slug
    # before_save       :set_visibility
    before_create     :add_to_list_bottom
    # after_create      :send_notifications

    ## named scopes ##
    scope :visible, :where => { :_visible => true }
    scope :latest_updated, :order_by => :updated_at.desc, :limit => Locomotive.config.lastest_items_nb

    ## methods ##

    alias :visible? :_visible?
    alias :_permalink :_slug
    alias :_permalink= :_slug=

    # def highlighted_field_value
    #   self.send(self.content_type.highlighted_field_name)
    # end
    #
    # alias :_label :highlighted_field_value

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

    def to_presenter
      Locomotive::ContentEntryPresenter.new(self)
    end

    def as_json(options = {})
      self.to_presenter.as_json
    end

    protected

    # Sets the slug of the instance by using the value of the highlighted field
    # (if available). If a sibling content instance has the same permalink then a
    # unique one will be generated
    def set_slug
      # self._slug = highlighted_field_value.dup if _slug.blank? && highlighted_field_value.present?
      #
      # if _slug.present?
      #   self._slug.permalink!
      #   self._slug = next_unique_slug if slug_already_taken?
      # end
    end

    # Return the next available unique slug as a string
    def next_unique_slug
      # slug        = _slug.gsub(/-\d*$/, '')
      # last_slug   = _parent.contents.where(:_id.ne => _id, :_slug => /^#{slug}-?\d*?$/i).order_by(:_slug).last._slug
      # next_number = last_slug.scan(/-(\d)$/).flatten.first.to_i + 1
      #
      # [slug, next_number].join('-')
    end

    # def slug_already_taken?
    #   _parent.contents.where(:_id.ne => _id, :_slug => _slug).any?
    # end

    # def set_visibility
    #   %w(visible active).map(&:to_sym).each do |_alias|
    #     if self.methods.include?(_alias)
    #       self._visible = self.send(_alias)
    #       return
    #     end
    #   end
    #   # field = self.content_type.contents_custom_fields.detect { |f| %w{visible active}.include?(f._alias) }
    #   # self._visible = self.send(field._name) rescue true
    # end

    def add_to_list_bottom
      # TODO
      # self._position_in_list = self.content_type.contents.size
    end

    # def require_highlighted_field
    #   _alias = self.highlighted_field_alias
    #   if self.send(_alias).blank?
    #     self.errors.add(_alias, :blank)
    #   end
    # end
    #
    # def highlighted_field_alias
    #   self.content_type.highlighted_field._alias.to_sym
    # end
    #
    # def send_notifications
    #   return unless self.content_type.api_enabled? && !self.content_type.api_accounts.blank?
    #
    #   accounts = self.content_type.site.accounts.to_a
    #
    #   self.content_type.api_accounts.each do |account_id|
    #     next if account_id.blank?
    #
    #     account = accounts.detect { |a| a.id.to_s == account_id.to_s }
    #
    #     Locomotive::Notifications.new_content_instance(account, self).deliver
    #   end
    # end

  end
end
