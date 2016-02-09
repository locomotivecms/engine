require 'database_cleaner'

# https://github.com/DatabaseCleaner/database_cleaner/issues/409
# https://docs.mongodb.org/v3.0/reference/command/listCollections/#dbcmd.listCollections
module DatabaseCleaner
  module Mongoid
    class Truncation

      private

      def collections
        if db != :default
          database.use(db)
        end

        database.collections.collect { |c| c.namespace.split('.', 2)[1] }
      end

    end
  end
end


