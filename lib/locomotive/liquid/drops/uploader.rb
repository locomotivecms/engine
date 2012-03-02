module Locomotive
  module Liquid
    module Drops
      class Uploader < Base

        delegate :url, :size, :to => '_source'

        def filename
          File.basename(self._source.url)
        end

      end
    end
  end
end