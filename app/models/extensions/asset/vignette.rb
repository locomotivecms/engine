module Extensions
  module Asset
    module Vignette

      def vignette_url
        if self.image?
          if self.width < 80 && self.height < 80
            self.source.url
          else
            self.source.url(:medium)
          end
        end
      end

    end
  end
end
