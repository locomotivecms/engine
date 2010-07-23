module CarrierWave
  module Uploader
    class Base

      def to_liquid
        {
          :url      => self.url,
          :filename => (File.basename(self.url) rescue ''),
          :size     => self.size
        }.stringify_keys
      end

    end
  end
end
