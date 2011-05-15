module Locomotive
  module Liquid
    module Filters
      module Resize

        def resize(input, *args)
          settings = get_settings(args_to_options(args))
          image_location(input, settings)
        end

        protected

        def image_location(input, settings)
          url                   = input.respond_to?(:url) ? input.url : input
          url_without_extension = "#{File.dirname(url)}/#{File.basename(url, File.extname(url))}"
          # Remove a dot at the start of the path (Occurs when a relative path is given)
          url_without_extension.slice!(0) if url_without_extension.start_with?('.')
          extension             = File.extname(url)
          "#{url_without_extension}_#{settings[:width]}x#{settings[:height]}#{extension}"
        end

        def get_settings(options)

          settings = {}
          settings[:width]  = options[:width].match(/\b(\d*)(px)?\b/).try(:[], 1)  if options[:width].present?
          settings[:height] = options[:height].match(/\b(\d*)(px)?\b/).try(:[], 1) if options[:height].present?

          if settings[:width].present? || settings[:height].present?
            settings
          else
            raise 'width or height is required'
          end
        end

        protected

        # Convert an array of properties ('key:value') into a hash
        # Ex: ['width:50', 'height:100'] => { :width => '50', :height => '100' }
        def args_to_options(*args)
          options = {}
          args.flatten.each do |a|
            if (a =~ /^(.*):(.*)$/)
              options[$1.to_sym] = $2
            end
          end
          options
        end

      end

      ::Liquid::Template.register_filter(Resize)

    end
  end
end
