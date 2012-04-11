module Locomotive
  module CarrierWave
    module Uploader
      module Asset

        extend ActiveSupport::Concern

        included do

          process :set_content_type
          process :set_size
          process :set_width_and_height
          version :compiled, :if => :wants_compilation? do
            process :compile_js_css
          end

        end

        module ClassMethods

          def content_types
            {
              :image      => ['image/jpeg', 'image/pjpeg', 'image/gif', 'image/png', 'image/x-png', 'image/jpg', 'image/x-icon'],
              :media      => [/^video/, 'application/x-shockwave-flash', 'application/x-flash-video', 'application/x-swf', /^audio/, 'application/ogg', 'application/x-mp3'],
              :pdf        => ['application/pdf', 'application/x-pdf'],
              :stylesheet => ['text/css'],
              :javascript => ['text/javascript', 'text/js', 'application/x-javascript', 'application/javascript', 'text/x-component'],
              :font       => ['application/x-font-ttf', 'application/vnd.ms-fontobject', 'image/svg+xml', 'application/x-woff'],
              :scss       => ['text/x-scss'],
              :coffeescript => ['text/x-coffeescript']
            }
          end
          
          
        end

        def set_content_type(*args)
          value = :other
          content_type = file.content_type == 'application/octet-stream' ? File.mime_type?(original_filename) : file.content_type

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
            magick = ::Magick::Image.read(current_path).first
            model.width, model.height = magick.columns, magick.rows
          end
        end

        def image?(file)
          model.image?
        end

        def wants_compilation?( text )
          model.respond_to?(:stylesheet_or_javascript?) and model.stylesheet_or_javascript? and model.compile?
        end

        def compile_js_css(*args)
          cache_stored_file! if !cached?
          if model.stylesheet?
            options = Locomotive.config.sass_process_options || {}
            options[:syntax] = :scss if options[:syntax].blank?
            options[:load_paths] = [] if options[:load_paths].blank?
            options[:load_paths] += ['.',File.dirname(current_path),File.expand_path(model.source.store_dir,Rails.public_path)]
            compiled = Sass::Engine.for_file( model.source.path, options ).render
          elsif model.javascript?
            options = Locomotive.config.coffeescript_process_options || {}
            compiled = CoffeeScript.compile(File.open(model.source.path).read,options )
          end
          File.open(current_path, "wb") { |f| f.write(compiled) } unless compiled.blank?
        rescue
          raise ::CarrierWave::ProcessingError, "#{$!}"
        end

      end
    end
  end
end
