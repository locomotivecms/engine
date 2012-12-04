# encoding: utf-8

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

    desc 'Fix issue with the editable file and i18n in the 2.0.0.rc'
    task :fix_editable_files => :environment do
      Locomotive::Page.all.each do |page|
        page.editable_elements.each_with_index do |el, index|
          next if el._type != 'Locomotive::EditableFile' || el.attributes['source'].is_a?(Hash)

          value = el.attributes['source']

          page.collection.update({ '_id' => page._id }, { '$unset' => { "editable_elements.#{index}.content" => 1 }, '$set' => { "editable_elements.#{index}.source" => { 'en' => value } } })
        end
      end
    end

    desc 'Make blocks and editable_elements consistent'
    task :make_editable_elements_consistent => :environment do
      Locomotive::Site.all.each do |site|
      # site = Locomotive::Site.find('50acd6f087f64350c9000010')
        site.locales.each do |locale|
          ::Mongoid::Fields::I18n.locale = locale
          # page = Locomotive::Page.find('50acd6f087f64350c9000012') # home page
          # page = Locomotive::Page.find('50ae35ff87f643f3df0000bc') # company
          site.pages.each do |page|
            puts "[#{site.name}] #{page.fullpath} (#{locale})"

            found_elements = []

            page.template.walk do |node, memo|
              case node
              when Locomotive::Liquid::Tags::InheritedBlock
                puts "found block ! #{node.name} --- #{memo[:parent_block_name]}"

                # set the new name based on a potential parent block
                name = node.name.gsub(/[\"\']/o, '')

                if memo[:parent_block_name] && !name.starts_with?(memo[:parent_block_name])
                  name = "#{memo[:parent_block_name]}/#{name}"
                end

                puts "new_name = #{name}"

                # retrieve all the editable elements of this block and set them the new name
                page.find_editable_elements(node.name).each do |el|
                  # puts "**> hurray found the element #{el.block} _ #{el.slug}"
                  el.block = name
                  puts "**> hurray found the element #{el.block} _ #{el.slug} | #{page.find_editable_element(name, el.slug).present?.inspect}"
                end

                # assign the new name to the block
                node.instance_variable_set :@name, name

                # record the new parent block name for children
                memo[:parent_block_name] = name

              when Locomotive::Liquid::Tags::Editable::ShortText,
                  Locomotive::Liquid::Tags::Editable::LongText,
                  Locomotive::Liquid::Tags::Editable::Control,
                  Locomotive::Liquid::Tags::Editable::File

                puts "\tfound editable_element ! #{node.slug} --- #{memo[:parent_block_name]}"

                slug = node.slug.gsub(/[\"\']/o, '')

                # assign the new slug to the editable element
                puts "\t\t...looking for #{node.slug} inside #{memo[:parent_block_name]}"

                options = node.instance_variable_get :@options
                block   = options[:block].blank? ? memo[:parent_block_name] : options[:block]

                if el = page.find_editable_element(block, node.slug)
                  puts "\t\t--> yep found the element"

                  el.slug   = slug
                  el.block  = memo[:parent_block_name] # just to make sure

                  node.instance_variable_set :@slug, slug

                  options.delete(:block)
                  node.instance_variable_set :@block, nil  # just to make sure

                  found_elements << el._id
                else
                  puts "\t\t[WARNING] el not found (#{block} - #{slug})"
                end

              end

              memo
            end # page walk

            puts "found elements = #{found_elements.join(', ')} / #{page.editable_elements.count}"

            # "hide" useless editable elements
            page.editable_elements.each do |el|
              next if found_elements.include?(el._id)
              el.disabled = true
            end

            # serialize
            page.send(:_serialize_template)

            # puts page.template.inspect

            # save ?
            page.instance_variable_set :@template_changed, false
            page.save

            # TODO:
            #  x ", block: 'Asset #1'"" ???? les re-assigner a "main" d'une facon ou d'une autre
            #   => en fait, ce sont des editable elements qui n'ont pas vrais blocks
            #  x hide useless editable elements
            #  x re-serializer le template
            #  ? skipper la methode parse (quoique pas besoin car template non modifie)
            #  x snippets
            #  x sauvegarder (sans callbacks ??)
          end # loop: pages
        end # loop: locales
      end # loop: sites
    end # task: make_editable_elements_consistent

  end # namespace: upgrade

  desc 'Generate the documentation about the REST API'
  task :generate_api_doc => :environment do

    require 'locomotive/misc/api_documentation'

    output = Locomotive::Misc::ApiDocumentation.generate

    path = File.join(Dir.pwd, 'public')

    File.open(File.join(path, 'locomotive_api.html'), 'w') do |file|
      file.write(output)
    end
  end

  namespace :maintenance do

    desc 'Unset the translation of the editable elements for a LOCALE'
    task :unset_editable_elements_translation => :environment do
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
            page.collection.update({ '_id' => page._id }, { '$set' => modifications })
          end
        end
      end
    end

  end

end
