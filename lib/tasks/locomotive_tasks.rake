# encoding: utf-8

namespace :locomotive do

  # desc 'Fetch the Locomotive default site template for the installation'
  # task fetch_default_site_template: :environment do
  #   puts "Downloading default site template from '#{Locomotive::Import.DEFAULT_SITE_TEMPLATE}'"
  #   `curl -L -s -o #{Rails.root}/tmp/default_site_template.zip #{Locomotive::Import.DEFAULT_SITE_TEMPLATE}`
  #   puts '...done'
  # end

  desc 'Add a new admin user (NOTE: currently only supports adding user to first site)'
  task add_admin: :environment do
    name = ask('Display name: ') { |q| q.echo = true }
    email = ask('Email address: ') { |q| q.echo = true }
    password = ask('Password: ') { |q| q.echo = '*' }
    password_confirm = ask('Confirm password: ') { |q| q.echo = '*' }

    account = Locomotive::Account.create email: email, password: password, password_confirmation: password_confirm, name: name

    # TODO: this should be changed to work for multi-sites (see desc)
    if site = Locomotive::Site.first
      site.memberships.build account: account, role: 'admin'
      site.save!
    end
  end

  namespace :upgrade do

    desc 'Upgrade to Locomotive v3 from v2.5.x'
    task v3: :environment do
      puts '...'

      # subdomain to handle
      Locomotive::Site.all.each_by(10) do |site|
        if subdomain = site.attributes['subdomain']
          site.set handle: subdomain
        end
      end
      puts '[x] set the handle attribute for all the sites'

      # number_of_entries by content type
      Locomotive::ContentType.all.each_by(10) do |content_type|
        content_type.set number_of_entries: content_type.entries.count
      end
      puts '[x] set the number of entries by content type'

      # content_entries: many_to_many relationships, make sure both sides are consistent
      Locomotive::ContentType.where('entries_custom_fields.type' => 'many_to_many').all.each_by(10) do |content_type|
        # puts "[#{content_type.site.name}] #{content_type.name}"
        content_type.entries_custom_fields.where('type' => 'many_to_many').all.each do |field|
          # puts "\t[#{content_type.name}][#{field.name}] #{field.label}"

          content_type.entries.each_by(10) do |entry|
            ids_name = "#{field.name.singularize}_ids"
            # puts "\t\t[#{content_type.name}][#{entry._id}][#{entry._slug}] #{entry.attributes[ids_name].inspect}"
            entry.send(field.name).each do |target_entry|
              target_ids_name = "#{field.inverse_of.singularize}_ids"
              target_ids      = target_entry.attributes[target_ids_name]

              if target_ids.nil?
                puts "[ERROR][#{content_type.site.name}] wrong many-to-many inverse_of key for #{content_type.name}"
                next
              end

              valid = target_ids.include?(entry._id)

              unless valid
                target_entry.send(target_ids_name.to_sym) << entry._id
                target_entry.save
                target_entry.reload

                valid = target_ids.include?(entry._id)
              end

              # puts "\t\t\t[#{content_type.name}][#{target_entry._id}][#{target_entry._slug}] inverse target ids: #{target_ids.inspect} | valid? #{valid.inspect}"
            end
          end
        end
      end
      puts '[x] make many_to_many relationships exist both sides'

      # content asset checksums
      Locomotive::ContentAsset.all.each do |asset|
        asset.send(:calculate_checksum)
        asset.save
      end
      puts '[x] generate checksums for existing content assets'

      # translation completion
      Locomotive::Translation.all.each do |translation|
        translation.send(:set_completion)
        translation.save
      end
      puts '[x] set completion for translations'

      puts "\nDone!"
    end

  end # namespace: upgrade


  namespace :maintenance do

    desc 'Delete items older than N_DAYS days (30 by default) from the activity feed'
    task clean_activity_feed: :environment do
      days      = (ENV['N_DAYS'] ? ENV['N_DAYS'].to_i : 30).days.ago
      criteria  = Locomotive::Activity.where(:created_at.lt => days)

      if (size = criteria.count) > 0
        criteria.destroy_all
        puts "#{size} items from the activity feed have been deleted"
      else
        puts "No items from the activity feed have been deleted"
      end
    end

    desc 'Unset the translation of the editable elements for a LOCALE'
    task unset_editable_elements_translation: :environment do
      if ENV['LOCALE'].blank?
        puts 'LOCALE is required'
      else
        locale  = ENV['LOCALE'].downcase
        pages   = ENV['SITE_ID'].blank? ? Locomotive::Page.all : Locomotive::Site.find(ENV['SITE_ID']).pages

        pages.each do |page|
          modifications = {}

          page.editable_elements.each_with_index do |el, index|
            next if ['Locomotive::EditableFile', 'Locomotive::EditableControl'].include?(el._type)

            if el.locales
              modifications["editable_elements.#{index}.locales"] = el.locales - [locale]
            end

            if el.content_translations
              modifications["editable_elements.#{index}.content"] = el.content_translations.delete_if { |_locale, _| _locale == locale }
            end

            if el.default_content_translations
              modifications["editable_elements.#{index}.default_content"] = el.default_content_translations.delete_if { |_locale, _| _locale == locale }
            end
          end

          # persist the modifications
          unless modifications.empty?
            page.collection.find(_id: page._id).update('$set' => modifications)
          end
        end
      end
    end

  end

end
