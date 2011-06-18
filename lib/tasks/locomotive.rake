# encoding: utf-8

require 'locomotive'

namespace :locomotive do

  desc 'Fetch the Locomotive default site template for the installation'
  task :fetch_default_site_template => :environment do
    puts "Downloading default site template from '#{Locomotive::Import.DEFAULT_SITE_TEMPLATE}'"
    `curl -L -s -o #{Rails.root}/tmp/default_site_template.zip #{Locomotive::Import.DEFAULT_SITE_TEMPLATE}`
    puts '...done'
  end

  namespace :upgrade do

    desc 'Remove asset collections and convert them into content types'
    task :remove_asset_collections => :environment do
      puts "asset_collection # ? #{AssetCollection.count}"

      AssetCollection.all.each do |collection|
        site = Site.find(collection.attributes['site_id'])

        if collection.internal?
          # internal collection => create simple assets without associated to a collection

          collection.assets.each do |tmp_asset|

            sanitized_attributes = tmp_asset.attributes.dup
            sanitized_attributes.delete_if { |k, v| [:name, :source_filename].include?(k) }
            sanitized_attributes[:_id] = tmp_asset._id

            asset = site.assets.build(sanitized_attributes)

            asset.source = tmp_asset.source.file

            asset.save!

            puts "asset = #{asset.inspect}"

            asset.destroy
          end
        else
          # create content_types reflection of an asset collection

          content_type = site.content_types.build({
            :name => collection.name,
            :slug => collection.slug,
            :order_by => 'manually'
          })

          # add default custom fields
          content_type.content_custom_fields.build(:label => 'Name', :slug => 'name', :kind => 'string', :required => true)
          content_type.content_custom_fields.build(:label => 'Source', :slug => 'source', :kind => 'file', :required => true)

          # extra custom fields
          collection.asset_custom_fields.each do |field|
            content_type.content_custom_fields.build(field.attributes)
          end

          # puts "new content_type = #{content_type.inspect}"

          # puts "valid ? #{content_type.valid?.inspect}"

          content_type.save
          content_type = ContentType.find(content_type._id)

          # insert data
          # puts "collection.assets = #{collection.ordered_assets.inspect} / #{collection.ordered_assets.class}"

          collection.ordered_assets.each do |asset|
            attributes = (if asset.custom_fields.blank?
              { :created_at => asset.created_at, :updated_at => asset.updated_at }
            else
              asset.aliased_attributes
            end)

            attributes.merge!(:name => asset.name, :_position_in_list => asset.position)

            # puts "attributes = #{attributes.inspect}"

            content = content_type.contents.build(attributes)

            content.source = asset.source.file

            content.save!

            puts "content = #{content.inspect}"
          end

          content_type.destroy
        end
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
  def site_id
    self.collection.site_id
  end
end
