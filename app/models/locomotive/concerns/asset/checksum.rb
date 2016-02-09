module Locomotive
  module Concerns
    module Asset

      module Checksum

        extend ActiveSupport::Concern

        included do
          ## fields ##
          field :checksum

          ## callbacks ##
          before_save :calculate_checksum
        end

        private

        def calculate_checksum
          begin
            self.checksum = Digest::MD5.hexdigest(self.source.read)
          rescue Errno::ENOENT => e
            # no file
          end
        end

      end

    end
  end
end

