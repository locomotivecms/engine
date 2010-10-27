module Admin::BoxHelper

  def box_flash_message
    if not flash.empty?
      content_tag :div, flash.values.first,
        :id => "flash-#{flash.keys.first}",
        :class => 'application-message'
    else
      ''
    end
  end

  def box_button_tag(label)
    content_tag(:button, content_tag(:span, label), :type => 'submit', :class => 'button')
  end

  def next_installation_step_link(step = 1, label = nil)
    link_to(content_tag(:span, label || t('admin.installation.common.next')), admin_installation_step_url(step), :class => 'button')
  end

end
