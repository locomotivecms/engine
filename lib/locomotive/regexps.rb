module Locomotive
  module Regexps

    SUBDOMAIN           = /^[a-z][a-z0-9_-]*[a-z0-9]{1}$/

    DOMAIN              = /^(([a-z\d])([a-z\d-]){0,61}([a-z\d]))(\.([a-z\d])([a-z\d-]){0,61}([a-z\d]))*$/i

    URL                 = /((http|https|ftp):\/)?\/\S*/

  end
end
