require "highline/import"

namespace :development do
  desc "Setup sites and account for development"
  task bootstrap: :environment do
    if Locomotive::Site.count > 0 || Locomotive::Account.count > 0
      puts "This will wipe out all sites and accounts"
      delete = ask "Are you sure that you want to delete all of them? (y/n)"
      if delete == "y"
        Mongoid.purge!
      else
        exit
      end
    end

    account = Locomotive::Account.new email: "admin@locomotivecms.com", password: "locomotive", password_confirmation: "locomotive", name: "Admin"
    account.api_key = 'd49cd50f6f0d2b163f48fc73cb249f0244c37074'
    account.save!

    site = Locomotive::Site.create! name: "LocomotiveCMS", subdomain: "locomotive", domains: ["www.example.com"]
    site.memberships.build account: account, role: 'admin'
    site.save!

    site = Locomotive::Site.create! name: "Sample site", subdomain: "sample"
    site.memberships.build account: account, role: 'admin'
    site.save!

    puts "Now you have a www.example.com site"
    puts "and a sample.example.com site as well. (add them to your /etc/hosts)"
    puts "You can login with admin@locomotivecms.com and \"locomotive\" password."
  end
end