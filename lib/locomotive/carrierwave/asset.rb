module Locomotive
  module CarrierWave
    module Uploader
      module Asset

        extend ActiveSupport::Concern

        included do |base|

          process :set_content_type_of_model
          process :set_size
          process :set_width_and_height

        end

        module ClassMethods

          def content_types
            {
              image:      ['image/jpeg', 'image/pjpeg', 'image/gif', 'image/png', 'image/x-png', 'image/jpg', 'image/x-icon', 'image/svg+xml'],
              media:      [/^video/, 'application/x-shockwave-flash', 'application/x-flash-video', 'application/x-swf', /^audio/, 'application/ogg', 'application/x-mp3'],
              pdf:        ['application/pdf', 'application/x-pdf'],
              stylesheet: ['text/css'],
              javascript: ['text/javascript', 'text/js', 'application/x-javascript', 'application/javascript', 'text/x-component', 'application/ecmascript'],
              font:       [/^application\/.*font/, 'application/x-font-ttf', 'application/vnd.ms-fontobject', 'application/x-woff', 'application/x-woff2', 'application/x-font-truetype', 'application/x-font-woff', 'application/x-font-woff2']
            }
          end

        end

        def set_content_type_of_model(*args)
          content_type = file.content_type

          if content_type.blank? || ['application/octet-stream'].include?(content_type)
            content_type = File.mime_type?(original_filename)
          end

          value = find_content_type_of_model(content_type)

          model.content_type = value
        end

        def set_size(*args)
          model.size = file.size
        end

        def set_width_and_height
          if model.image?
            dragonfly_img = ::Dragonfly.app(:engine).fetch_file(current_path)
            begin
              model.width, model.height = dragonfly_img.width, dragonfly_img.height
            rescue Exception => e
              Rails.logger.error "[Dragonfly] Unable to get the width and the height, error: #{e.message}\n#{e.backtrace.join("\n")}"
            end
          end
        end

        def image?(file)
          model.image?
        end

        def find_content_type_of_model(content_type)
          value = :other

          self.class.content_types.each_pair do |type, rules|
            rules.each do |rule|
              case rule
              when String then value = type if content_type == rule
              when Regexp then value = type if (content_type =~ rule) == 0
              end
            end
          end

          apply_content_type_exception(value)
        end

        def apply_content_type_exception(value)
          # by default, do nothing
          value
        end

      end
    end
  end
end
