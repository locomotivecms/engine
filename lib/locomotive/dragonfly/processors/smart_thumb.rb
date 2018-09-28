module Locomotive
  module Dragonfly
    module Processors

      # Do the following steps to get a thumb of an image:
      # 1. resize
      # 2. crop
      # 3. optimize
      #
      # It doesn't try to resize and crop at the same time as the default thumb processor does
      class SmartThumb < ::Dragonfly::ImageMagick::Processors::Thumb

        RESIZE_CROP_GEOMETRY = /\A(\d+)x(\d+)\|(\d+)x(\d+)([+-]\d+)?([+-]\d+)?\z/ # e.g. '3840x5760|1920x320+10+10'

        def args_for_geometry(geometry)
          case geometry
          when RESIZE_CROP_GEOMETRY
            smart_resize_and_crop_args(
              width:        $1,
              height:       $2,
              crop_width:   $3,
              crop_height:  $4,
              x:            $5,
              y:            $6
            )
          else
            super
          end
        end

        private

        def smart_resize_and_crop_args(opts)
          "-resize #{opts[:width]}x#{opts[:height]}^^ -gravity Northwest -crop #{opts[:crop_width]}x#{opts[:crop_height]}#{opts[:x]}#{opts[:y]} +repage"
        end

      end
    end
  end
end
