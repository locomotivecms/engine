class ActionView::Base

  def escape_json(json)
    json.html_safe
  end
end
