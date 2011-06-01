require 'bushido'
require 'jammit'
require 'net/http'

namespace :bushido do
  desc "Prepare an app to run on the Bushido hosting platform, only called during the initial installation. Called just before booting the app."
  task :install => :environment do

    # re-built assets
    Jammit.package!

    if ENV['BUSHIDO_USER_EMAIL'] && ENV['BUSHIDO_USER_ID']
      # already logged in in Bushido
      account = Account.create!({
        :email            => ENV['BUSHIDO_USER_EMAIL'],
        :name             => ENV['BUSHIDO_USER_NAME'] || ENV['BUSHIDO_USER_EMAIL'].split('@').first,
        :bushido_user_id  => ENV['BUSHIDO_USER_ID'],
        :password         => ActiveSupport::SecureRandom.base64(6)
      })
    else
      # create an anonymous account right away
      account = Account.create!({
        :email      => "#{ENV['BUSHIDO_APP']}@#{ENV['BUSHIDO_HOST']}",
        :name       => ENV['BUSHIDO_APP'],
        :password   => ActiveSupport::SecureRandom.base64(6)
      })
    end

    # create the site
    site = Site.create_first_one(:name => ENV['LOCOMOTIVE_SITE_NAME'] || ENV['BUSHIDO_APP'])

    # fetch the site template
    template_url = ENV['SITE_TEMPLATE_URL'] || Locomotive::Import::DEFAULT_SITE_TEMPLATE
    template_url = "http://#{template_url}" unless template_url =~ /^https?:\/\//

    template_local_path = "#{Rails.root}/permanent/site_template.zip"

    uri = URI.parse(template_url)
    http = Net::HTTP.new(uri.host, uri.port)

    if template_url.starts_with?('https') # ssl request ?
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    case http.request(Net::HTTP::Get.new(uri.request_uri))
    when Net::HTTPSuccess, Net::HTTPFound
      `curl -L -s -o #{template_local_path} #{template_url}`

      tmp, Locomotive.config.delayed_job = Locomotive.config.delayed_job, false # disable DJ during this import

      Locomotive::Import::Job.run!(File.open(template_local_path), site, { :samples => true })

      Locomotive.config.delayed_job = tmp # restore DJ flag
    else
      # do nothing
    end
  end

  desc "Perform custom actions triggered by the Bushido hosting platform."
  task :event => :environment do
    event = ::Bushido::Event.last

    puts "processing...#{event.inspect}"

    case event.category.to_s
    when 'app'
      case event.name.to_s
      when 'claimed'
        # an user has just claimed his application
        account = Account.order_by(:created_at).first

        account.email = event.data['bushido_user_email']
        account.bushido_user_id = event.data['bushido_user_id']

        account.save!
      end
    end
  end

  desc "Prepare an app to run on the Bushido hosting platform, called on every update. Called just before booting the app."
  task :update do
    # re-built assets
    Jammit.package!
  end
end

