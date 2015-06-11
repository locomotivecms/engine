module CarrierWave

  class SanitizedFile

    # FIXME (Did) CarrierWave speaks mime type now
    def content_type_with_file_mime_type
      content_type_without_file_mime_type || File.mime_type?(original_filename)
    end

    alias_method_chain :content_type, :file_mime_type

  end

  module Uploader

    module Base64Download

      # Based on Yury Lebedev's work (https://github.com/lebedev-yury/carrierwave-base64)
      # Our version relies on the remote_<name>_url field. Moreover, we support passing filename into the base64 string.
      class Base64StringIO < StringIO
        class ArgumentError < StandardError; end

        attr_accessor :file_format, :original_filename

        def initialize(encoded_file)
          description, encoded_bytes = encoded_file.split(",")

          raise ArgumentError unless encoded_bytes

          @file_format        = get_file_format(description)
          @original_filename  = get_original_filename(description)

          bytes = ::Base64.decode64 encoded_bytes

          super bytes
        end

        private

        def get_original_filename(description)
          regex = /\Adata:[^;]+;(.+);base64\Z/
          regex.match(description).try(:[], 1) || default_filename
        end

        def get_file_format(description)
          regex = /\Adata:([^;]+);/
          regex.match(description).try(:[], 1)
        end

        def default_filename
          File.basename("file.#{@file_format}")
        end

      end

      def download!(uri_or_base64)
        if uri_or_base64 =~ /\Adata:/
          file = Base64StringIO.new(uri_or_base64)
          cache!(file)
        else
          download_without_base64!(uri_or_base64)
        end
      end

    end

    class Base

      alias :download_without_base64! :download!
      include CarrierWave::Uploader::Base64Download

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
