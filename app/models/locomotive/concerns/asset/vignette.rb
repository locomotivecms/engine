module Locomotive
  module Concerns
    module Asset
      module Vignette

        def vignette_url
          if self.image?
            # In some case (like an invalid extension) the height, width can be nill
            # In that case we should directly return the url
            if self.width && self.height && self.width < 85 && self.height < 85
              self.source.url
            else
              Locomotive::Dragonfly.resize_url(self.source, '85x85#', self.updated_at.to_i)
            end
          elsif self.pdf?
            Locomotive::Dragonfly.thumbnail_pdf(self.source, '85x85#', self.updated_at.to_i)
          end
        end

        def alternative_vignette_url
          format = if self.image? && self.width && self.height
            '190x120>'
          elsif self.pdf?
            '190x120#'
          end

          Locomotive::Dragonfly.thumbnail_pdf(self.source, format, self.updated_at.to_i) if format
        end

        def big_vignette_url
          format = if self.image? || self.pdf?
            '200x200#'
          end

          Locomotive::Dragonfly.thumbnail_pdf(self.source, format, self.updated_at.to_i) if format
        end

      end
    end
  end
end
