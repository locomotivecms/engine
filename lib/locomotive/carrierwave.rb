require 'carrierwave/processing/mime_types'

require 'locomotive/carrierwave/base'
require 'locomotive/carrierwave/asset'
require 'locomotive/carrierwave/patches'

# register missing mime types
EXTENSIONS[:eot] = 'application/vnd.ms-fontobject'
EXTENSIONS[:woff] = 'application/x-woff'
EXTENSIONS[:otf] = 'application/octet-stream'

# Allow retina images
CarrierWave::SanitizedFile.sanitize_regexp = /[^a-zA-Z0-9\.\-\+_\@]/