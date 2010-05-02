class Layout < LiquidTemplate

  ## associations ##
  embeds_many :parts, :class_name => 'PagePart'
  
  ## callbacks ##
  before_save :build_parts_from_value
  
  ## validations ##
  validates_format_of :value, :with => Locomotive::Regexps::CONTENT_FOR_LAYOUT, :message => :missing_content_for_layout
  
  ## methods ##
  
  protected
  
  def build_parts_from_value
    if self.value_changed? || self.new_record?
      self.parts = []

      (groups = self.value.scan(Locomotive::Regexps::CONTENT_FOR)).each do |part|
        part[1].strip!
        part[1] = nil if part[1].empty?
        
        slug = part[0].strip.downcase
        
        name = (if slug == 'layout'
          I18n.t('admin.shared.attributes.body')
        else
          (part[1] || slug).gsub("\"", '')
        end)
        
        self.parts.build :slug => slug, :name => name
      end
    end
  end
  
end