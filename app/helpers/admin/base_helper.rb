module Admin::BaseHelper
    
  def admin_menu_item(name, url)
    label = content_tag(:em) + escape_once('&nbsp;') + t("admin.shared.menu.#{name}")
    content_tag(:li, link_to(label, url), :class => name.dasherize)
  end
  
  def admin_button_tag(text, url, options = {})
    text = text.is_a?(Symbol) ? t(".#{text}") : text    
    link_to(url, options) do
      content_tag(:span, text)
    end
  end
  
end