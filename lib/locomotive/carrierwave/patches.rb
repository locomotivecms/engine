require 'carrierwave'

module CarrierWave

  class SanitizedFile

    def original_filename=(filename)
      @original_filename = filename
    end

    def content_type=(content_type)
      @content_type = content_type
    end

    # http://github.com/jnicklas/carrierwave/issuesearch?state=closed&q=content+type#issue/48
    def copy_to_with_content_type(new_path, permissions=nil)
      new_file = self.copy_to_without_content_type(new_path, permissions)
      new_file.content_type = self.content_type
      new_file
    end

    alias_method_chain :copy_to, :content_type

    # FIXME (Did) CarrierWave speaks mime type now
    def content_type
      return @content_type if @content_type
      if @file.respond_to?(:content_type) and @file.content_type
        @file.content_type.chomp
      else
        File.mime_type?(@file) if @file.is_a?(String)
      end
    end

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
