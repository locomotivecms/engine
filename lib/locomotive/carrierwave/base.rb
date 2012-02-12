module CarrierWave
  module Uploader
    class Base

      def to_liquid
        uploader = self

        (Hash.new do |h, key|
          if key == 'size' || key == :size
            h[key] = uploader.size
          end
        end).tap do |h|
          h['url'] = self.url
          h["filename"] = (File.basename(self.url) rescue '')
        end
      end

    end
  end
end
