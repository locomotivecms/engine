# encoding: utf-8

require 'locomotive'
require 'highline/import'

namespace :locomotive do

  desc 'Fetch the Locomotive default site template for the installation'
  task :fetch_default_site_template => :environment do
    puts "Downloading default site template from '#{Locomotive::Import.DEFAULT_SITE_TEMPLATE}'"
    `curl -L -s -o #{Rails.root}/tmp/default_site_template.zip #{Locomotive::Import.DEFAULT_SITE_TEMPLATE}`
    puts '...done'
  end

  desc 'Rebuild the serialized template of all the site pages'
  task :rebuild_serialized_page_templates => :environment do
    Locomotive::Site.all.each do |site|
      pages = site.pages.to_a
      while !pages.empty? do
        page = pages.pop
        begin
          page.send :_parse_and_serialize_template
          page.save
          puts "[#{site.name}] processing...#{page.title}"
        rescue TypeError => e
          pages.insert(0, page)
        end
      end
    end
  end

  # desc 'Import a remote template described by its URL -- 2 options: SITE=name or id, RESET=by default false'
  # task :import => :environment do
  #   url, site_name_or_id, reset = ENV['URL'], ENV['SITE'], Boolean.set(ENV['RESET']) || false
  #
  #   if url.blank? || (url =~ /https?:\/\//).nil?
  #     raise "URL is missing or it is not a valid http url."
  #   end
  #
  #   site = Locomotive::Site.find(site_name_or_id) || Locomotive::Site.where(:name => site_name_or_id).first || Locomotive::Site.first
  #
  #   if site.nil?
  #     raise "No site found. Please give a correct value (name or id) for the SITE env variable."
  #   end
  #
  #   ::Locomotive::Import::Job.run!(url, site, { :samples => true, :reset => reset })
  # end

  desc 'Add a new admin user (NOTE: currently only supports adding user to first site)'
  task :add_admin => :environment do
    name = ask('Display name: ') { |q| q.echo = true }
    email = ask('Email address: ') { |q| q.echo = true }
    password = ask('Password: ') { |q| q.echo = '*' }
    password_confirm = ask('Confirm password: ') { |q| q.echo = '*' }

    account = Locomotive::Account.create :email => email, :password => password, :password_confirmation => password_confirm, :name => name

    # TODO: this should be changed to work for multi-sites (see desc)
    site = Locomotive::Site.first
    site.memberships.build :account => account, :role => 'admin'
    site.save!
  end

  namespace :upgrade do

    desc "Index page is sometimes after the 404 error page. Fix this"
    task :place_index_before_404 => :environment do
      Locomotive::Site.all.each do |site|
        site.pages.root.first.update_attribute :position, 0
        site.pages.not_found.first.update_attribute :position, 1
      end
    end

    desc "Namespace collections"
    task :namespace_collections do
      db = Mongoid.config.master['sites'].db
      db.collections.each do |collection|
        next if collection.name =~ /^locomotive_/ # already namespaced

        new_name = "locomotive_#{collection.name}"
        new_name = "locomotive_content_assets" if collection.name =~ /^assets/

        puts "renaming #{collection.name} into #{new_name}"
        collection.rename_collection new_name
      end
    end

    desc "Upgrade a site to i18n. Requires SITE (name or id) and LOCALE (by default: en) as env variables"
    task :i18n => :environment do
      locale, site_name_or_id = ENV['LOCALE'] || 'en', ENV['SITE']

      site = Locomotive::Site.find(site_name_or_id) || Locomotive::Site.where(:name => site_name_or_id).first

      raise 'Site not found' if site.nil?

      site.locales ||= [locale]

      # sites
      %w(seo_title meta_keywords meta_description).each do |attribute|
        if !site.send(:"#{attribute}_translations").respond_to?(:keys)
          site.changed_attributes.store attribute, site.attributes[attribute]
          site.attributes.store attribute, { locale => site.attributes[attribute] }
        end
      end
      site.save!

      puts "======="

      # TODO https://github.com/mongodb/mongo-ruby-driver

      Locomotive::Page.skip_callback(:validate, :before)
      Locomotive::Page.skip_callback(:save, :after)

      Locomotive::Page.all.each do |page|
        begin
          %w(title slug fullpath raw_template seo_title meta_keywords meta_description serialized_template template_dependencies snippet_dependencies).each do |attribute|
            if !page.send(:"#{attribute}_translations").respond_to?(:keys)
              page.changed_attributes.store attribute, page.attributes[attribute]
              page.attributes.store attribute, { locale => page.attributes[attribute] }
            end
          end
          page.save(:validate => false)
        rescue Exception => e
          puts "Error: #{e.message}, page = #{page.title}"
          puts e.backtrace
          raise "STOP a first error"
        end
      end
    end

  end

end
