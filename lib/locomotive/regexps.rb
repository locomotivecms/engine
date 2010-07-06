module Locomotive
  module Regexps
    
    SUBDOMAIN           = /^[a-z][a-z0-9]*[a-z0-9]{1}$/
    
    DOMAIN              = /^[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ix
    
    CONTENT_FOR         = /\{\{\s*content_for_([a-zA-Z]{1}[a-zA-Z_0-9]*)(\s+.*)?\s*\}\}/
    
    CONTENT_FOR_LAYOUT  = /\{\{\s*content_for_layout\s*/
    
  end
end