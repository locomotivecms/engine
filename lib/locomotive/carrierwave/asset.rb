module Locomotive
  module CarrierWave
    module Uploader
      module Asset

        extend ActiveSupport::Concern

        included do |base|

          include ::CarrierWave::MimeTypes

          process :set_content_type
          process :set_content_type_of_model
          process :set_size
          process :set_width_and_height

        end

        module ClassMethods

          def content_types
            {
              image:      ['image/jpeg', 'image/pjpeg', 'image/gif', 'image/png', 'image/x-png', 'image/jpg', 'image/x-icon'],
              media:      [/^video/, 'application/x-shockwave-flash', 'application/x-flash-video', 'application/x-swf', /^audio/, 'application/ogg', 'application/x-mp3'],
              pdf:        ['application/pdf', 'application/x-pdf'],
              stylesheet: ['text/css'],
              javascript: ['text/javascript', 'text/js', 'application/x-javascript', 'application/javascript', 'text/x-component'],
              font:       [/^application\/.*font/, 'application/x-font-ttf', 'application/vnd.ms-fontobject', 'image/svg+xml', 'application/x-woff', 'application/x-woff2', 'application/x-font-truetype', 'application/x-font-woff', 'application/x-font-woff2']
            }
          end

        end

        def set_content_type_of_model(*args)
          value         = :other
          content_type  = file.content_type

          if content_type.blank? || content_type == 'application/octet-stream'
            content_type = File.mime_type?(original_filename)
          end

          self.class.content_types.each_pair do |type, rules|
            rules.each do |rule|
              case rule
              when String then value = type if content_type == rule
              when Regexp then value = type if (content_type =~ rule) == 0
              end
            end
          end

          model.content_type = value
        end

        def set_size(*args)
          model.size = file.size
        end

        def set_width_and_height
          if model.image?
            dragonfly_img = Dragonfly.app.fetch_file(current_path)
            model.width, model.height = dragonfly_img.width, dragonfly_img.height
          end
        end

        def image?(file)
          model.image?
        end

      end
    end
  end
end
