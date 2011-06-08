require 'dragonfly/rails/images'

Dragonfly[:images].configure do |c|

  # Convert absolute location needs to be specified
  # to avoid issues with Phusion Passenger not using $PATH
  convert = `which convert`.strip.presence || "/usr/local/bin/convert"
  c.convert_command  = convert
  c.identify_command = convert

  c.allow_fetch_url  = true
  c.allow_fetch_file = true
end
