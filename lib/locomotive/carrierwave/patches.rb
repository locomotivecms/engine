require 'carrierwave'

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

module CarrierWave
  module Mongoid
    def validates_integrity_of(*attrs)
      options = attrs.last.is_a?(Hash) ? attrs.last : {}
      validates_each(*attrs) do |record, attr, value|
        if record.send("#{attr}_integrity_error")
          message = options[:message] || I18n.t('carrierwave.errors.integrity', :default => 'is not an allowed type of file.')
          record.errors.add attr, message
        end
      end
    end

    def validates_processing_of(*attrs)
      options = attrs.last.is_a?(Hash) ? attrs.last : {}
      validates_each(*attrs) do |record, attr, value|
        if record.send("#{attr}_processing_error")
          message = options[:message] || I18n.t('carrierwave.errors.processing', :default => 'failed to be processed.')
          record.errors.add attr, message
        end
      end
    end
  end
end
