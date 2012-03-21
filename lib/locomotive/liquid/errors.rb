module Locomotive
  module Liquid
    class PageNotFound < ::Liquid::Error; end

    class PageNotTranslated < ::Liquid::Error; end
  end
end