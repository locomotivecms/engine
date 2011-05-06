module Locomotive
  module Liquid
    module Filters
      module Imagetransform

        def transform(input, transform_string)
          transform_settings = interpolate_transform(input, transform_string)
          
        end

        protected

        def interpolate_transform(input, transform_string)

          matches   = transform_string.match(/\b(\d*)x?(\d*)\b([\>\<\#\@\%^!])?/i)
          width     = matches[0].to_i || 0
          height    = matches[1].to_i || 0
          modifyer  = matches[3]      || '#'

          unless width > 0 && height > 0 && modifyers[modifyer].present?
            raise "invalid format for transform on #{input}"
          end

        end

        # TODO: Check if these modifyers are actually correct :)
        def modifyers
          { 
            '#' => :resize_to_fit,
            '>' => :resize_to_fill
          }
        end

      end

      ::Liquid::Template.register_filter(Imagetransform)


    end
  end
end
