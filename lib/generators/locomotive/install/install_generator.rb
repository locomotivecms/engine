module Locomotive
  class InstallGenerator < Rails::Generators::Base

    def self.source_root
      @_locomotive_source_root ||= File.expand_path("../templates", __FILE__)
    end

    def copy_initializer
      template "locomotive.rb", "config/initializers/locomotive.rb"
    end

  end
end