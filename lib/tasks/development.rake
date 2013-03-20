require "highline/import"

namespace :development do
  task :bootstrap => :environment do
    if Locomotive::Site.count > 0 || Locomotive::Account.count > 0
      puts "This will wipe out all sites and accounts"
      delete = ask "Are you sure that you want to delete all of them? (y/n)"
      if delete == "y"
        Mongoid.master.collections.select {|c| c.name !~ /system/ }.each(&:drop)
      else
        exit
      end
    end
    
    account = Locomotive::Account.create! :email => "admin@locomotivecms.com", :password => "locomotive", :password_confirmation => "locomotive", :name => "Admin"

    site = Locomotive::Site.create! name: "LocomotiveCMS", subdomain: "locomotive", domains: ["www.example.com"]
    site.memberships.build :account => account, :role => 'admin'
    site.save!
    
    site = Locomotive::Site.create! name: "Sample site", subdomain: "sample"
    site.memberships.build :account => account, :role => 'admin'
    site.save!
    
    puts "Now you have a www.sample.com site"
    puts "and a sample.example.com site as well. (add them to your /etc/hosts)"
    puts "You can login with admin@locomotivecms.com and \"locomotive\" password."
  end
end