module CarrierWave

  class SanitizedFile

    # FIXME (Did) CarrierWave speaks mime type now
    def content_type_with_file_mime_type
      mt = content_type_without_file_mime_type
      mt.blank? || mt == 'text/plain' ? File.mime_type?(original_filename) : mt
    end

    alias_method_chain :content_type, :file_mime_type

  end

  module Uploader

    module Store
      # unfortunately carrierwave does not support an easy way of changing
      # version file extensions
      def store_path(for_file=filename)
        File.join([store_dir, full_filename(for_file)].compact).gsub(/(compiled_[^\.]+\.)(scss|coffee)$/) do
          "#{$1}#{$2=='scss'? 'css':'js'}" 
        end
      end
    end


    class Base

      def build_store_dir(*args)
        default_dir = self.class.store_dir

        if default_dir.blank? || default_dir == 'uploads'
          File.join(args.map(&:to_s))
        else
          File.join([default_dir] + args.map(&:to_s))
        end
      end

    end

  end

end
