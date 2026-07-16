module CarrierWave

  # This method returns the minimal host of the current storage.
  # For instance, if the chosen storage is AWS S3, then it returns
  # something similar to https://<BUCKET>.s3-<REGION>.amazonaws.com.
  # The returned value is bound to the current storage.
  #
  # Special case: if the storage is file, then it'll return nil
  #
  def self.base_host
    # don't treat the 'file' storage
    storage_klass = CarrierWave::Uploader::Base.storage.to_s
    return nil if CarrierWave::Uploader::Base.storage_engines.invert[storage_klass] == :file

    uploader = CarrierWave::Uploader::Base.new
    uploader.retrieve_from_store!(nil)

    uploader.url.gsub('/' + uploader.path, '')
  end

  module Uploader

    module Base64Download

      # Based on Yury Lebedev's work (https://github.com/lebedev-yury/carrierwave-base64)
      # Our version relies on the remote_<name>_url field. Moreover, we support passing filename into the base64 string.
      class Base64StringIO < StringIO
        class ArgumentError < StandardError; end

        attr_accessor :file_format, :original_filename

        def initialize(encoded_file)
          description, encoded_bytes = encoded_file.split(',')

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

      def download!(uri_or_base64, remote_headers = {})
        if uri_or_base64 =~ /\Adata:/
          file = Base64StringIO.new(uri_or_base64)
          cache!(file)
        else
          download_without_base64!(uri_or_base64, remote_headers)
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

  # FIXME: The carrierwave store_dir of the ContentEntry model was not correctly set up.
  #
  # The consequence is the following bug:
  #
  # - context: a content entry has 2 file fields with 2 uploaded files sharing the same filename
  # - action: we delete one of the 2 files.
  # - result: the second file will be erased too.
  #
  # The solution is to not delete a file if inside the same model, we find another file field
  # sharing the same file identifier.
  #
  # CarrierWave 2 deletes files flagged with remove_<column> through
  # Mounter#remove_previous (after save) instead of Mounter#remove!, so the
  # guard lives there now. One more adaptation is required: when the remove
  # flag is set, remember the real identifier, otherwise the Mongoid
  # dirty-tracking sentinel ('_new_') would be used as the file name to
  # delete, silently orphaning the real file.
  #
  module SafeRemove

    def remove=(value)
      super

      if remove?
        record.instance_variable_set(:"@_previous_uploader_value_for_#{column}",
                                     record.read_uploader(serialization_column))
      end
    end

    def remove_previous(before = nil, after = nil)
      if before.present?
        kept   = kept_identifiers
        before = before.reject { |value| value.is_a?(String) && kept.include?(value) }
      end

      super(before, after)
    end

    private

    def kept_identifiers
      record.class.uploaders.keys.reject { |_column| _column == column }.filter_map do |_column|
        next if record.send(:_mounter, _column).remove?

        record.send(_column)&.identifier
      end
    end

  end

  class Mounter

    prepend SafeRemove

  end
end
