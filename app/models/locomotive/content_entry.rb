module Locomotive
  class ContentEntry

    include Locomotive::Mongoid::Document

    ## extensions ##
    include ::CustomFields::Target
    include Extensions::Shared::Seo

    ## fields ##
    field :_slug
    field :_label_field_name
    field :_position, :type => Integer, :default => 0
    field :_visible,  :type => Boolean, :default => true

    ## validations ##
    validates :_slug, :presence => true, :uniqueness => { :scope => :content_type_id }

    ## associations ##
    belongs_to  :site,          :class_name => 'Locomotive::Site'
    belongs_to  :content_type,  :class_name => 'Locomotive::ContentType', :inverse_of => :entries

    ## callbacks ##
    before_validation :set_slug
    before_save       :set_site
    before_save       :set_visibility
    before_save       :set_label_field_name
    before_create     :add_to_list_bottom
    after_create      :send_notifications

    ## named scopes ##
    scope :visible, :where => { :_visible => true }
    scope :latest_updated, :order_by => :updated_at.desc, :limit => Locomotive.config.ui[:latest_entries_nb]

    ## methods ##

    alias :visible? :_visible?
    alias :_permalink :_slug
    alias :_permalink= :_slug=

    def _label(type = nil)
      value = if self._label_field_name
        self.send(self._label_field_name.to_sym)
      else
        self.send((type || self.content_type).label_field_name.to_sym)
      end

      value.respond_to?(:to_label) ? value.to_label : value.to_s
    end

    alias :to_label :_label

    def translated?
      if self.respond_to?(:"#{self._label_field_name}_translations")
        self.send(:"#{self._label_field_name}_translations").key?(::Mongoid::Fields::I18n.locale.to_s) #rescue false
      else
        true
      end
    end

    def next
      next_or_previous :gt
    end

    def previous
      next_or_previous :lt
    end

    def self.find_by_permalink(permalink)
      self.where(:_slug => permalink).first
    end

    def self.sort_entries!(ids)
      list = self.any_in(:_id => ids.map { |id| BSON::ObjectId.from_string(id.to_s) }).to_a
      ids.each_with_index do |id, position|
        if entry = list.detect { |e| e._id.to_s == id.to_s }
          entry.update_attributes :_position => position
        end
      end
    end

    def to_liquid
      Locomotive::Liquid::Drops::ContentEntry.new(self)
    end

    def to_presenter(options = {})
      Locomotive::ContentEntryPresenter.new(self, options)
    end

    def as_json(options = {})
      self.to_presenter(options).as_json
    end

    protected

    def next_or_previous(matcher = :gt)
      order_by  = self.content_type.order_by_definition
      criterion = :_position.send(matcher)

      self.class.where(criterion => self._position).order_by([order_by]).limit(1).first
    end

    # Sets the slug of the instance by using the value of the highlighted field
    # (if available). If a sibling content instance has the same permalink then a
    # unique one will be generated
    def set_slug
      self._slug = self._label.dup if self._slug.blank? && self._label.present?

      if self._slug.present?
        self._slug.permalink!
        self._slug = self.next_unique_slug if self.slug_already_taken?
      end
    end

    # Return the next available unique slug as a string
    def next_unique_slug
      slug        = self._slug.gsub(/-\d*$/, '')
      last_slug   = self.class.where(:_id.ne => self._id, :_slug => /^#{slug}-?\d*?$/i).order_by(:_slug).last._slug
      next_number = last_slug.scan(/-(\d)$/).flatten.first.to_i + 1
      [slug, next_number].join('-')
    end

    def slug_already_taken?
      self.class.where(:_id.ne => self._id, :_slug => self._slug).any?
    end

    def set_site
      self.site ||= self.content_type.site
    end

    def set_visibility
      if self.respond_to?(:visible)
        self.visible  = true if self.visible.nil?
        self._visible = self.visible
        return
      end
    end

    def set_label_field_name
      self._label_field_name = self.content_type.label_field_name
    end

    def add_to_list_bottom
      self._position = self.class.max(:_position).to_i + 1
    end

    def send_notifications
      return if !self.content_type.public_submission_enabled? || self.content_type.public_submission_accounts.blank?

      self.site.accounts.each do |account|
        next unless self.content_type.public_submission_accounts.map(&:to_s).include?(account._id.to_s)

        Locomotive::Notifications.new_content_entry(account, self).deliver
      end
    end

  end
end
