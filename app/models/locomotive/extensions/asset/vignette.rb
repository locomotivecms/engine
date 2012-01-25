module Locomotive
  module Extensions
    module Asset
      module Vignette

        def vignette_url
          if self.image?
            if self.width < 85 && self.height < 85
              self.source.url
            else
              Locomotive::Dragonfly.resize_url(self.source, '85x85#')
            end
          end
        end

      end
    end
  end
end