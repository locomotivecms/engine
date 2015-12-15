module Locomotive
  module Concerns
    module Asset
      module Vignette

        def vignette_url
          if self.image?
            if self.width < 85 && self.height < 85
              self.source.url
            else
              Locomotive::Dragonfly.resize_url(self.source, '85x85#')
            end
          elsif self.pdf?
            Locomotive::Dragonfly.thumbnail_pdf(self.source, '85x85#')
          end
        end

        def alternative_vignette_url
          format = if self.image? && self.width && self.height
            '190x120>'
          elsif self.pdf?
            '190x120#'
          end

          Locomotive::Dragonfly.thumbnail_pdf(self.source, format) if format
        end

      end
    end
  end
end
