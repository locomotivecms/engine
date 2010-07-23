module Locomotive
  class InstallGenerator < Rails::Generators::Base

    def self.source_root
      @_locomotive_source_root ||= File.expand_path('../templates', __FILE__)
    end

    def copy_initializer
      template 'locomotive.rb', 'config/initializers/locomotive.rb'
    end

    def seed_db
      append_file 'db/seeds.rb', %{
# Uncomment the following lines if you want to create the first website / account
#account = Account.create! :name => 'Admin', :email => 'admin@example.com', :password => 'locomotive', :password_confirmation => 'locomotive'
#site = Site.new :name => 'Locomotive test website', :subdomain => 'test'
#site.memberships.build :account => account, :admin => true
#site.save!}
    end

    def show_readme
      readme 'README'
    end

  end
end
