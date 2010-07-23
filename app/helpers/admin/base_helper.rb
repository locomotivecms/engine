module Admin::BaseHelper

  def title(title = nil)
    if title.nil?
      @content_for_title
    else
      @content_for_title = title
      ''
    end
  end

  def admin_menu_item(name, url)
    label = content_tag(:em) + escape_once('&nbsp;') + t("admin.shared.menu.#{name}")
    content_tag(:li, link_to(label, url), :class => name.dasherize)
  end

  def admin_button_tag(text, url, options = {})
    text = text.is_a?(Symbol) ? t(".#{text}") : text
    link_to(url, options) do
      content_tag(:em, escape_once('&nbsp;')) + text
    end
  end

  def admin_submenu_item(name, url, options = {}, &block)
    default_options = { :i18n => true, :css => name.dasherize.downcase }
    default_options.merge!(options)

    css = "#{'on' if name == sections(:sub)} #{'links' if block_given?} #{options[:css]}"

    label_link = default_options[:i18n] ? t("admin.shared.menu.#{name}") : name
    if block_given?
      popup = content_tag(:div, capture(&block), :class => 'popup', :style => 'display: none')
      link = link_to(content_tag(:span, preserve(label_link + content_tag(:em))), url)
      content_tag(:li, link + popup, :class => css)
    else
      content_tag(:li, link_to(content_tag(:span, label_link), url), :class => css)
    end
  end

  def growl_message
    if not flash.empty?
      %{
        $(document).ready(function() {
          $.growl("#{flash.keys.first}", "#{flash.values.first}");
        });
      }.to_s
    end
  end

  def nocoffee_tag
    link_to 'noCoffee', 'http://www.nocoffee.fr', :id => 'nocoffee'
  end

end
