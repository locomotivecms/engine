# encoding: utf-8

class AssetUploader < CarrierWave::Uploader::Base

  include CarrierWave::RMagick

  def store_dir
    self.build_store_dir('sites', model.collection.site_id, 'assets', model.id)
  end

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

  process :set_content_type
  process :set_size
  process :set_width_and_height

  def set_content_type(*args)
    value = :other

    content_type = file.content_type == 'application/octet-stream' ? File.mime_type?(original_filename) : file.content_type

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

  def set_size(*args)
    model.size = file.size
  end

  def set_width_and_height
    if model.image?
      magick = ::Magick::Image.read(current_path).first
      model.width, model.height = magick.columns, magick.rows
    end
  end

  def image?
    model.image?
  end

  def self.content_types
    {
      :image      => ['image/jpeg', 'image/pjpeg', 'image/gif', 'image/png', 'image/x-png', 'image/jpg', 'image/x-icon'],
      :media      => [/^video/, 'application/x-shockwave-flash', 'application/x-swf', /^audio/, 'application/ogg', 'application/x-mp3'],
      :pdf        => ['application/pdf', 'application/x-pdf'],
      :stylesheet => ['text/css'],
      :javascript => ['text/javascript', 'text/js', 'application/x-javascript', 'application/javascript'],
      :font       => ['application/x-font-ttf', 'application/vnd.ms-fontobject', 'image/svg+xml', 'application/x-woff']
    }
  end

end
