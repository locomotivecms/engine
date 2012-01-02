module Locomotive
  class ContentEntry

    include Locomotive::Mongoid::Document

    ## extensions ##
    include ::CustomFields::Target
    include Extensions::Shared::Seo

    ## fields ##
    field :_slug
    field :_position, :type => Integer, :default => 0
    field :_visible,  :type => Boolean, :default => true

    ## validations ##
    validates :_slug, :presence => true, :uniqueness => { :scope => :content_type_id }

    ## associations ##
    belongs_to  :site
    belongs_to  :content_type, :class_name => 'Locomotive::ContentType', :inverse_of => :entries

    ## callbacks ##
    before_validation :set_slug
    before_save       :set_visibility
    before_create     :add_to_list_bottom
    # after_create      :send_notifications

    ## named scopes ##
    scope :visible, :where => { :_visible => true }
    scope :latest_updated, :order_by => :updated_at.desc, :limit => Locomotive.config.lastest_entries_nb

    ## methods ##

    alias :visible? :_visible?
    alias :_permalink :_slug
    alias :_permalink= :_slug=

    def _label(type = nil)
      self.send((type || self.content_type).label_field_name.to_sym)
    end

    def visible?
      self._visible || self._visible.nil?
    end

    def next
      next_or_previous :gt
    end

    def previous
      next_or_previous :lt
    end

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

    def next_or_previous(matcher = :gt)
      attribute = self.content_type.order_by.to_sym
      direction = self.content_type.order_direction || 'asc'
      criterion = attribute.send(matcher)

      self.class.where(criterion => self.send(attribute)).order_by([[attribute, direction]]).limit(1).first
    end

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

    def set_visibility
      [:visible, :active].each do |meth|
        if self.respond_to?(meth)
          self._visible = self.send(meth)
          return
        end
      end
    end

    def add_to_list_bottom
      self._position = self.class.max(:_position).to_i + 1
    end

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
