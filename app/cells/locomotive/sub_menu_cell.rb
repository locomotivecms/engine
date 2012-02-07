module Locomotive
  class SubMenuCell < MenuCell

    protected

    def build_item(name, attributes)
      item = super
      enhanced_class = "#{'on' if name.to_s == sections(:sub).to_s} #{item[:class]}"
      item.merge(:class => enhanced_class)
    end

  end
end