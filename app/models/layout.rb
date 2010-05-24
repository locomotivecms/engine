class Layout < LiquidTemplate

  ## associations ##
  has_many_related :pages
  embeds_many :parts, :class_name => 'PagePart'
  
  ## callbacks ##
  before_save :build_parts_from_value
  after_save :update_parts_in_pages
  
  ## validations ##
  validates_format_of :value, :with => Locomotive::Regexps::CONTENT_FOR_LAYOUT, :message => :missing_content_for_layout
  
  ## methods ##
  
  protected
  
  def build_parts_from_value
    if self.value_changed? || self.new_record?
      self.value.scan(Locomotive::Regexps::CONTENT_FOR).each do |attributes|
        slug = attributes[0].strip.downcase
        name = attributes[1].strip.gsub("\"", '')    
        name = nil if name.empty?
        name ||= I18n.t('attributes.defaults.page_parts.name') if slug == 'layout'
        
        if part = self.parts.detect { |p| p.slug == slug }
          part.name = name if name.present?
        else
          self.parts.build :slug => slug, :name => name || slug
        end        
      end
      
      # body always first
      body = self.parts.detect { |p| p.slug == 'layout' }
      self.parts.delete(body)
      self.parts.insert(0, body)
      
      @_update_pages = true if self.value_changed?
    end
  end
  
  def update_parts_in_pages
    self.pages.each { |p| p.send(:update_parts!, self.parts) } if @_update_pages
  end  
  
end