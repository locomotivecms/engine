module Admin::BaseHelper
  
  def admin_menu_item(name, url)
    label = content_tag(:em) + escape_once('&nbsp;') + t("admin.shared.menu.#{name}")
    content_tag(:li, link_to(label, url), :class => name.dasherize)
  end
  
end