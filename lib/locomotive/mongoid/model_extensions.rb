Dir[File.join(File.dirname(__FILE__), '..', '..', '..', 'app', 'models', 'extensions', '**', '*.rb')].each { |lib| require lib }
