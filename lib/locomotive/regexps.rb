module Locomotive
  module Regexps

    HANDLE              = /^[a-z][a-z0-9_-]*[a-z0-9]{1}$/

    DOMAIN              = /^(([a-z\d])([a-z\d-]){0,61}([a-z\d]))(\.([a-z\d])([a-z\d-]){0,61}([a-z\d]))*$/i

    URL                 = /\A((https?:\/\/)|(ftp:\/))\S+\Z/

    URL_AND_MAILTO      = /\A((https?:\/\/\S+)|(ftp:\/\S+)|(mailto:\S+)|\/\S*)\Z/

  end
end
