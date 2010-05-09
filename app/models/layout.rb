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
      self.parts.clear

      body = nil

      self.value.scan(Locomotive::Regexps::CONTENT_FOR).each do |part|
        part[1].strip!
        part[1] = nil if part[1].empty?
        
        slug = part[0].strip.downcase
        
        if slug == 'layout'          
          body = PagePart.new :slug => slug, :name => I18n.t('admin.shared.attributes.body')
        else
          self.parts.build :slug => slug, :name => (part[1] || slug).gsub("\"", '')
        end
      end
      
      self.parts.insert(0, body) if body
      
      @_update_pages = true if self.value_changed?
    end
  end
  
  def update_parts_in_pages
    self.pages.each { |p| p.send(:update_parts!, self.parts) } if @_update_pages
  end  
  
end