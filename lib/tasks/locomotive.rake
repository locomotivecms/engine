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

    desc 'Migrate from 1.0 to 2.0'
    task :migration_2_0 => :environment do
      db = Mongoid.config.master

      # # assets -> locomotive_content_assets
      # if collection = db.collections.detect { |c| c.name == 'assets' }
      #   new_collection = db.collections.detect { |c| c.name == 'locomotive_content_assets' }
      #   new_collection.drop if new_collection
      #   collection.rename 'locomotive_content_assets'
      # end

      # content_types -> locomotive_content_types
      if collection = db.collections.detect { |c| c.name == 'content_types' }
        # new_collection = db.collections.detect { |c| c.name == 'locomotive_content_types' }
        # new_collection.drop if new_collection
        # collection.rename 'locomotive_content_types'

        # contents_collection = db.collections.detect { |c| c.name == 'locomotive_content_entries' }
        # contents_collection = db.create_collection('locomotive_content_entries') if contents_collection.nil?

        collection.update({}, {
          '$rename' => {
            'api_enabled'                   => 'public_submission_enabled',
            'api_accounts'                  => 'public_submission_accounts',
            'content_custom_fields'         => 'entries_custom_fields',
            'content_custom_fields_version' => 'entries_custom_fields_version',
          },
          '$unset' => {
            'content_custom_fields_counter' => '1'
          }
        })

        collection.update({}, {
          '$rename' => {
            'entries_custom_fields._alias'          => 'entries_custom_fields.name',
            'entries_custom_fields.kind'            => 'entries_custom_fields.type',
            'entries_custom_fields.category_items'  => 'entries_custom_fields.select_options'
          }
        })

        collection.find.each do |content_type|
          label_field_name  = ''
          operations        = { '$set' => {}, '$unset' => {} }
          contents          = content_type['contents']
          custom_fields     = content_type['entries_custom_fields']

          custom_fields.each_with_index do |field, index|
            class_name = "Locomotive::Entry#{field['target'][-24,24]}" if field['target']

            case field['type']
            when 'category'
              operations['$set'].merge!("entries_custom_fields.#{index}.type" => 'select')
            when 'has_one'
              operations['$set'].merge!("entries_custom_fields.#{index}.type" => 'belongs_to')
            when 'has_many'
              if field['reverse_lookup']
                operations['$set'].merge!("entries_custom_fields.#{index}.type" => 'has_many')

                # reverse_lookup -> inverse_of
                if _content_type = collection.find('_id' => BSON::ObjectId(field['target'][-24,24]).first)
                  if _field = _content_type['entries_custom_fields'].detect { |f| f['_name'] == field['reverse_lookup'] }
                    operations['$set'].merge!("entries_custom_fields.#{index}.inverse_of" => _field['_alias'])
                  end
                end
              else
                operations['$set'].merge!("entries_custom_fields.#{index}.type" => 'many_to_many')
              end
            end

            if %w(has_one has_many).include?(field['type'])
              operations['$set'].merge!("entries_custom_fields.#{index}.class_name" => class_name)
              operations['$unset'].merge!({
                "entries_custom_fields.#{index}.target"         => '1',
                "entries_custom_fields.#{index}.reverse_lookup" => '1'
              })
            end
          end

          # contents
          contents.each_with_index do |content|
            attributes = content.clone.keep_if { |k, v| %w(_id _slug seo_title meta_description meta_keywords _visible created_at updated_at).include?(k) }
            attributes.merge!({
              'content_type_id'     => content_type['_id'],
              'site_id'             => content_type['site_id'],
              '_position'           => content['_position_in_list'],
              '_type'               => "Locomotive::Entry#{content_type['_id']}",
              '_label_field_name'   => label_field_name
            })

            custom_fields.each do |field|
              name, _name = field['name'], field['_name']

              case field['type'] # string, text, boolean, date, file, category, has_many, has_one
              when 'string', 'text', 'boolean', 'date', 'file'
                attributes[name] = content[_name]
              when 'category', 'has_one'
                attributes["#{name}_id"] = content[_name]
              when 'has_many'
                if field['reverse_lookup']
                  # nothing to do
                else
                  attributes["#{name}_ids"] = content[_name]
                end
              end
            end

            # insert document
            # contents_collection.insert attributes
            puts attributes.inspect
          end

          # TODO: change highlighted_field_name + for each field, change category -> select

          # save content _type
          # collection.update { '_id' => content_type['_id'] }, operations

          puts operations.inspect

          print "================================= END ========================="
        end

        # collection.update({}, {
        #   '$unset' => {
        #     'entries_custom_fields._name' => '1',
        #     'contents'                    => '1',
        #     'highlighted_field_name'      => '1',
        #     'group_by_field_name'         => '1'
        #   }
        # })
      end


    end



    # desc "Index page is sometimes after the 404 error page. Fix this"
    # task :place_index_before_404 => :environment do
    #   Locomotive::Site.all.each do |site|
    #     site.pages.root.first.update_attribute :position, 0
    #     site.pages.not_found.first.update_attribute :position, 1
    #   end
    # end
    #
    # desc "Namespace collections"
    # task :namespace_collections do
    #   db = Mongoid.config.master['sites'].db
    #   db.collections.each do |collection|
    #     next if collection.name =~ /^locomotive_/ # already namespaced
    #
    #     new_name = "locomotive_#{collection.name}"
    #     new_name = "locomotive_content_assets" if collection.name =~ /^assets/
    #
    #     puts "renaming #{collection.name} into #{new_name}"
    #     collection.rename_collection new_name
    #   end
    # end
    #
    # desc "Upgrade a site to i18n. Requires SITE (name or id) and LOCALE (by default: en) as env variables"
    # task :i18n => :environment do
    #   locale, site_name_or_id = ENV['LOCALE'] || 'en', ENV['SITE']
    #
    #   site = Locomotive::Site.find(site_name_or_id) || Locomotive::Site.where(:name => site_name_or_id).first
    #
    #   raise 'Site not found' if site.nil?
    #
    #   site.locales ||= [locale]
    #
    #   # sites
    #   %w(seo_title meta_keywords meta_description).each do |attribute|
    #     if !site.send(:"#{attribute}_translations").respond_to?(:keys)
    #       site.changed_attributes.store attribute, site.attributes[attribute]
    #       site.attributes.store attribute, { locale => site.attributes[attribute] }
    #     end
    #   end
    #   site.save!
    #
    #   Locomotive::Page.skip_callback(:validate, :before)
    #   Locomotive::Page.skip_callback(:save, :after)
    #
    #   Locomotive::Page.all.each do |page|
    #     %w(title slug fullpath raw_template seo_title meta_keywords meta_description serialized_template template_dependencies snippet_dependencies).each do |attribute|
    #       if !page.send(:"#{attribute}_translations").respond_to?(:keys)
    #         page.changed_attributes.store attribute, page.attributes[attribute]
    #         page.attributes.store attribute, { locale => page.attributes[attribute] }
    #       end
    #     end
    #     page.save(:validate => false)
    #   end
    # end

  end

end
