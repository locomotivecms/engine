module ApplicationHelper
  
  def title(title = nil)
    if title.nil?
      @content_for_title
    else
      @content_for_title = title
      ''
    end
  end
  
  def flash_message
    if not flash.empty?
      content_tag :div, flash.values.first, 
        :id => "flash-#{flash.keys.first}", 
        :class => 'application-message'
    else
      ''
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
    link_to content_tag(:em, 'no') + 'Coffee', 'http://www.nocoffee.fr', :id => 'nocoffee'
  end
  
  def submit_button_tag(label)
    content_tag(:button, content_tag(:span, label), :type => 'submit', :class => 'button')
  end
  
end
