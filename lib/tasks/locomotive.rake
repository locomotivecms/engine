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
    Site.all.each do |site|
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

  desc 'Import a remote template described by its URL -- 2 options: SITE=name or id, RESET=by default false'
  task :import => :environment do
    url, site_name_or_id, reset = ENV['URL'], ENV['SITE'], Boolean.set(ENV['RESET']) || false

    if url.blank? || (url =~ /https?:\/\//).nil?
      raise "URL is missing or it is not a valid http url."
    end

    site = Site.find(site_name_or_id) || Site.where(:name => site_name_or_id).first || Site.first

    if site.nil?
      raise "No site found. Please give a correct value (name or id) for the SITE env variable."
    end

    ::Locomotive::Import::Job.run!(url, site, { :samples => true, :reset => reset })
  end

  desc 'Add a new admin user (NOTE: currently only supports adding user to first site)'
  task :add_admin => :environment do
    name = ask('Display name: ') { |q| q.echo = true }
    email = ask('Email address: ') { |q| q.echo = true }
    password = ask('Password: ') { |q| q.echo = '*' }
    password_confirm = ask('Confirm password: ') { |q| q.echo = '*' }

    account = Account.create :email => email, :password => password, :password_confirmation => password_confirm, :name => name

    # TODO: this should be changed to work for multi-sites (see desc)
    site = Site.first
    site.memberships.build :account => account, :role => 'admin'
    site.save!
  end

  namespace :upgrade do

    desc 'Set roles to the existing users'
    task :set_roles => :environment do
      Site.all.each do |site|
        site.memberships.each do |membership|
          if membership.attributes['admin'] == true
            puts "...[#{site.name}] #{membership.account.name} has now the admin role"
            membership.role = 'admin'
          else
            puts "...[#{site.name}] #{membership.account.name} has now the author role"
            membership.role = 'author'
          end
        end
        site.save
      end
    end

    desc "Index page is sometimes after the 404 error page. Fix this"
    task :place_index_before_404 => :environment do
      Site.all.each do |site|
        site.pages.root.first.update_attribute :position, 0
        site.pages.not_found.first.update_attribute :position, 1
      end
    end

    desc 'Remove asset collections and convert them into content types'
    task :remove_asset_collections => :environment do
      puts "Processing #{AssetCollection.count} asset collection(s)..."

      Asset.destroy_all

      AssetCollection.all.each do |collection|
        site = Site.find(collection.attributes['site_id'])

        if collection.internal?
          # internal collection => create simple assets without associated to a collection

          collection.assets.each do |tmp_asset|
            # puts "tmp asset = #{tmp_asset.inspect} / #{tmp_asset.source.url.inspect}" TODO

            sanitized_attributes = tmp_asset.attributes.dup
            sanitized_attributes[:_id] = tmp_asset._id

            asset = site.assets.build(sanitized_attributes)

            asset.save(:validate => false)

            # puts "asset = #{asset.inspect} / #{asset.source.url.inspect}" TODO
          end
        else
          collection.fetch_asset_klass.class_eval { def self.model_name; 'Asset'; end }

          # create content_types reflection of an asset collection
          ContentType.where(:slug => collection.slug).all.collect(&:destroy) # TODO

          content_type = site.content_types.build({
            :name => collection.name,
            :slug => collection.slug,
            :order_by => '_position_in_list'
          })

          content_type._id = collection._id

          # extra custom fields
          collection.asset_custom_fields.each_with_index do |field, i|
            content_type.content_custom_fields.build(field.attributes.merge(:position => i + 3))
          end

          # add default custom fields
          content_type.content_custom_fields.build(:label => 'Name', :_alias => 'name', :kind => 'string', :required => true, :position => 1)
          content_type.content_custom_fields.build(:label => 'Source', :_alias => 'source', :kind => 'file', :required => true, :position => 2)

          content_type.save!

          content_type = ContentType.find(content_type._id) # hard reload

          # set the highlighted field name
          field = content_type.content_custom_fields.detect { |f| f._alias == 'name' }
          content_type.highlighted_field_name = field._name
          content_type.save

          # insert data
          collection.ordered_assets.each do |asset|
            attributes = (if asset.custom_fields.blank?
              { :created_at => asset.created_at, :updated_at => asset.updated_at }
            else
              {}.tap do |h|
                asset.custom_fields.each do |field|
                  case field.kind
                  when 'file' then h["#{field._name}"] = asset.send("#{field._name}".to_sym)
                  else
                    h[field._alias] = asset.send(field._name.to_sym)
                  end
                end
              end
            end)

            attributes.merge!(:name => asset.name, :_position_in_list => asset.position)

            content = content_type.contents.build(attributes)

            content._id = asset._id

            content.source = asset.source.file

            content.save(:validate => false)
          end
        end

        puts "...the collection named '#{collection.slug}' for the '#{site.name}' site has been migrated with success !"
      end
    end

  end

end


class TmpAssetUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick
  include Locomotive::CarrierWave::Uploader::Asset
  version :thumb, :if => :image? do
    process :resize_to_fill => [50, 50]
    process :convert => 'png'
  end
  version :medium, :if => :image? do
    process :resize_to_fill => [80, 80]
    process :convert => 'png'
  end
  version :preview, :if => :image? do
    process :resize_to_fit => [880, 1100]
    process :convert => 'png'
  end
  def store_dir
    self.build_store_dir('sites', model.collection.site_id, 'assets', model.id)
  end
end

# Classes only used during the upgrade mechanism. Will be removed in a few weeks
class AssetCollection
  include Locomotive::Mongoid::Document
  field :name
  field :slug
  field :internal, :type => Boolean, :default => false
  referenced_in :site
  embeds_many :assets, :class_name => 'TmpAsset', :validate => false
  custom_fields_for :assets
  after_destroy :remove_uploaded_files
  scope :internal, :where => { :internal => true }
  scope :not_internal, :where => { :internal => false }
  def ordered_assets
    self.assets.sort { |a, b| (a.position || 0) <=> (b.position || 0) }
  end
  def self.find_or_create_internal(site)
    site.asset_collections.internal.first || site.asset_collections.create(:name => 'system', :slug => 'system', :internal => true)
  end
end

class TmpAsset
  include Mongoid::Document
  include Mongoid::Timestamps
  include CustomFields::ProxyClassEnabler
  field :name, :type => String
  field :content_type, :type => String
  field :width, :type => Integer
  field :height, :type => Integer
  field :size, :type => Integer
  field :position, :type => Integer, :default => 0
  mount_uploader :source, TmpAssetUploader
  embedded_in :collection, :class_name => 'AssetCollection', :inverse_of => :assets
  def site_id; self.collection.site_id; end
end
