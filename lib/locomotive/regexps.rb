module Locomotive
  module Regexps

    SUBDOMAIN           = /^[a-z][a-z0-9_-]*[a-z0-9]{1}$/

    DOMAIN              = /^[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ix

    URL                 = /((http|https|ftp):\/)?\/\S*/

  end
end
