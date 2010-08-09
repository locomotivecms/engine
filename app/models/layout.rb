class Layout < LiquidTemplate

  ## fields ##
  # field :blocks, :type => Hash

  # def unmarshalled_blocks
  #   # puts "self.blocks = #{self.blocks.class.inspect}"
  #   @unmarshalled_blocks ||= self.blocks.inject({}) do |b, (name, node)|
  #     # puts "b= #{b.inspect} / name = #{name.inspect} / node = #{node.inspect}"
  #     b[name] = Marshal.load(node)
  #     b
  #   end
  # end

  protected



  def after_parse_template
    blocks = self.find_blocks(self.template.root)
    self.template.send(:instance_variable_set, :"@parent_blocks", blocks)

    # TODO: include parent blocks in self.template before marshalling it

    # puts "[Layout / blocks] #{self.blocks.inspect}"
  end

  def find_blocks(node, blocks = {})
    # puts "[Layout/#{self.slug}] ** find_blocks #{node.class.inspect} / #{blocks.keys.inspect}"
    if node.respond_to?(:nodelist) && node.nodelist
      # puts "  ==> find_blocks nodelist = #{node.nodelist.inspect}"
      node.nodelist.inject(blocks) do |b, node|
        if node.is_a?(Locomotive::Liquid::Tags::Block)
          # b[node.name] = Marshal.dump(node)
          b[node.name] = node
        end
        # else
        self.find_blocks(node, b) # FIXME: add nested blocks
        # end
        b
      end
    end
    blocks
  end

  ## associations ##

  # references_many :pages
  # embeds_many :parts, :class_name => 'PagePart'

  ## callbacks ##
  # before_save :build_parts_from_value
  # after_save :update_parts_in_pages

  ## validations ##
  # validates_format_of :value, :with => Locomotive::Regexps::CONTENT_FOR_LAYOUT, :message => :missing_content_for_layout

  ## methods ##

  # protected
  #
  # def build_parts_from_value
  #   if self.value_changed? || self.new_record?
  #     self.parts.each { |p| p.disabled = true }
  #
  #     self.value.scan(Locomotive::Regexps::CONTENT_FOR).each do |attributes|
  #       slug = attributes[0].strip.downcase
  #       name = slug.humanize
  #       name = I18n.t('attributes.defaults.page_parts.name') if slug == 'layout'
  #
  #       if part = self.parts.detect { |p| p.slug == slug }
  #         part.name = name if name.present?
  #         part.disabled = false
  #       else
  #         self.parts.build :slug => slug, :name => name || slug
  #       end
  #     end
  #
  #     # body always first
  #     body = self.parts.detect { |p| p.slug == 'layout' }
  #     self.parts.delete(body)
  #     self.parts.insert(0, body)
  #
  #     @_update_pages = true if self.value_changed?
  #   end
  # end
  #
  # def update_parts_in_pages
  #   self.pages.each { |p| p.send(:update_parts!, self.parts) } if @_update_pages
  # end

end
