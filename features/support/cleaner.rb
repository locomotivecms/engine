require 'database_cleaner'
DatabaseCleaner.strategy = :truncation
DatabaseCleaner.orm = "mongoid"
Before{ DatabaseCleaner.clean }
