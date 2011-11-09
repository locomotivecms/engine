module CarrierWave

  class SanitizedFile

    # FIXME (Did) CarrierWave speaks mime type now
    def content_type_with_file_mime_type
      content_type_without_file_mime_type || File.mime_type?(original_filename)
    end

    alias_method_chain :content_type, :file_mime_type

  end

  module Uploader

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
