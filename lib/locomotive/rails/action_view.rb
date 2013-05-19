# http://jfire.io/blog/2012/04/30/how-to-securely-bootstrap-json-in-a-rails-view/
class ActionView::Base

  JSON_ESCAPE_MAP = {
    "/" => '\/'
  }

  if "ruby".encoding_aware?
    JSON_ESCAPE_MAP["\342\200\250".force_encoding('UTF-8').encode!] = '&#x2028;'
    JSON_ESCAPE_MAP["\342\200\251".force_encoding('UTF-8').encode!] = '&#x2029;'
  else
    JSON_ESCAPE_MAP["\342\200\250"] = '&#x2028;'
    JSON_ESCAPE_MAP["\342\200\251"] = '&#x2029;'
  end

  def escape_json(json)
    if json
      result = json.gsub(/(\/|\342\200\250|\342\200\251)/u) { |match| JSON_ESCAPE_MAP[match] }
      json.html_safe? ? result.html_safe : result
    else
      ''
    end
  end

end