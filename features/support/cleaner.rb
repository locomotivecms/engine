require 'database_cleaner'
Before do
  DatabaseCleaner.clean
end
DatabaseCleaner.strategy = :truncation
DatabaseCleaner.orm = "mongoid"