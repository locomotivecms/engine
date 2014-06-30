module Locomotive
  module Liquid
    module Drops
      class Uploader < Base

        delegate :size, to: :@_source

        def url
          url, timestamp = @_source.url, @_source.model.updated_at.to_i

          @context.registers[:asset_host].compute(url, timestamp)
        end

        def filename
          File.basename(@_source.url)
        end

      end
    end
  end
end