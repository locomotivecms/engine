module Locomotive
  module Concerns
    module Account

      # More information here: https://github.com/mongoid/mongoid/issues/3626
      module DevisePatch

        extend ActiveSupport::Concern

        module ClassMethods

          def serialize_from_session(key, salt)
            (key = key.first) if key.kind_of? Array
            (key = BSON::ObjectId.from_string(key['$oid'])) if key.kind_of? Hash

            record = to_adapter.get(key)
            record if record && record.authenticatable_salt == salt
          end

          def serialize_into_session(record)
            [record.id.to_s, record.authenticatable_salt]
          end

        end

      end

    end
  end
end
