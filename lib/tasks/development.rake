require "highline/import"

namespace :development do
  task :bootstrap => :environment do
    if Locomotive::Site.count > 0
      puts "This will wipe out all sites and accounts"
      delete = ask "Are you sure that you want to delete all of them? (y/n)"
      if delete == "y"
        Locomotive::Site.destroy_all
        Locomotive::Account.destroy_all
      else
        exit
      end
    end
    
    site = Locomotive::Site.create! name: "LocomotiveCMS", subdomain: "locomotive"
    account = Locomotive::Account.create! :email => "admin@locomotivecms.com", :password => "locomotive", :password_confirmation => "locomotive", :name => "Admin"
    site.memberships.build :account => account, :role => 'admin'
    site.save!
    
    puts "Now you have a locomotive.engine.dev site (add this domain in /etc/hosts pointing to localhost)."
    puts "You can login with admin@locomotivecms.com and \"locomotive\" password."
  end
end