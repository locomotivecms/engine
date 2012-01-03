class Admin::SubMenuCell < ::Admin::MenuCell

  protected

  def build_item(name, attributes)
    item = super
    enhanced_class = "#{'on' if name.to_s == sections(:sub)} #{item[:class]}"
    item.merge(:class => enhanced_class)
  end

end
