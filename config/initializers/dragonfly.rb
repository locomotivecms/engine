require 'dragonfly/rails/images'

Dragonfly[:images].configure do |c|
  c.allow_fetch_url  = true
  c.allow_fetch_file = true
end
