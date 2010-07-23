module Admin::LoginHelper

  def login_flash_message
    if not flash.empty?
      content_tag :div, flash.values.first,
        :id => "flash-#{flash.keys.first}",
        :class => 'application-message'
    else
      ''
    end
  end

  def login_button_tag(label)
    content_tag(:button, content_tag(:span, label), :type => 'submit', :class => 'button')
  end

end
