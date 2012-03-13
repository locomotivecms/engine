# encoding: utf-8

# require 'locomotive'
# require 'highline/import'

namespace :locomotive do

  # desc 'Fetch the Locomotive default site template for the installation'
  # task :fetch_default_site_template => :environment do
  #   puts "Downloading default site template from '#{Locomotive::Import.DEFAULT_SITE_TEMPLATE}'"
  #   `curl -L -s -o #{Rails.root}/tmp/default_site_template.zip #{Locomotive::Import.DEFAULT_SITE_TEMPLATE}`
  #   puts '...done'
  # end

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

    desc "Fix issue with the editable file and i18n in the 2.0.0.rc"
    task :fix_editable_files => :environment do
      Locomotive::Page.all.each do |page|
        page.editable_elements.each_with_index do |el, index|
          next if el._type != 'Locomotive::EditableFile' || el.attributes['source'].is_a?(Hash)

          value = el.attributes['source']

          page.collection.update({ '_id' => page._id }, { '$unset' => { "editable_elements.#{index}.content" => 1 }, '$set' => { "editable_elements.#{index}.source" => { 'en' => value } } })
        end
      end
    end

  end

end
