module CarrierWave
  module Uploader
    class Base

      def to_liquid
        Locomotive::Liquid::Drops::Uploader.new(self)
      end

    end
  end
end
