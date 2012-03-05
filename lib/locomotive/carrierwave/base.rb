module CarrierWave
  module Uploader
    class Base

      def to_label
        File.basename(self.to_s, File.extname(self.to_s))
      end

      def to_liquid
        Locomotive::Liquid::Drops::Uploader.new(self)
      end

    end
  end
end
