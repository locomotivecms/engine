# encoding: utf-8

class ThemeAssetUploader < CarrierWave::Uploader::Base

  include CarrierWave::RMagick

  # Choose what kind of storage to use for this uploader
  # storage :file
  # storage :s3

  # Override the directory where uploaded files will be stored
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "sites/#{model.site_id}/themes/#{model.id}"
  end
  
  version :thumb do
    process :resize_to_fill => [50, 50]
    process :convert => 'png'
  end
  
  version :medium do
    process :resize_to_fill => [80, 80]
    process :convert => 'png'
  end

  version :preview do
    process :resize_to_fit => [880, 1100]
    process :convert => 'png'    
  end
  
  process :set_content_type  
  process :set_size
  process :set_width_and_height

  def set_content_type
    value = :other
    
    content_type = File.mime_type?(original_filename) if file.content_type == 'application/octet-stream'
    
    self.class.content_types.each_pair do |type, rules|
      rules.each do |rule|
        case rule
        when String then value = type if content_type == rule
        when Regexp then value = type if (content_type =~ rule) == 0
        end
      end
    end
    
    model.content_type = value
  end
  
  def set_size
    model.size = file.size
  end
  
  def set_width_and_height
    if model.image?
      model.width, model.height = `identify -format "%wx%h" #{file.path}`.split(/x/).collect(&:to_i)
    end
  end
    
  def self.content_types
    {
      :image      => ['image/jpeg', 'image/pjpeg', 'image/gif', 'image/png', 'image/x-png', 'image/jpg'],
      :stylesheet => ['text/css'],
      :javascript => ['text/javascript', 'text/js', 'application/x-javascript']
    }  
  end
  
  def extension_white_list
    %w(jpg jpeg gif png css js)
  end
  
  def filename
    if model.slug.present?
      model.filename
    else
      extension = File.extname(original_filename)
      basename = File.basename(original_filename, extension).slugify(:underscore => true)
      "#{basename}#{extension}"
    end
  end
  
end
