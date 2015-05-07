require 'carrierwave/test/matchers'

CarrierWave.configure do |config|
  config.storage = :file
  config.cache_dir = "spec/tmp/cache"
  config.root = File.join(Rails.root, 'spec', 'tmp')
end

module FixturedAsset
  def self.open(filename)
    File.new(self.path(filename))
  end

  def self.path(filename)
    File.join(File.dirname(__FILE__), '..', 'fixtures', 'assets', filename)
  end

  def self.duplicate(filename)
    dst = File.join(File.dirname(__FILE__), '..', 'tmp', filename)
    FileUtils.cp self.path(filename), dst
    dst
  end

  def self.reset!
    FileUtils.rm_rf(File.join(File.dirname(__FILE__), '..', 'tmp'))
    FileUtils.mkdir(File.join(File.dirname(__FILE__), '..', 'tmp'))
  end
end
FixturedAsset.reset!

def rack_asset(filename)
  file = FixturedAsset.open(filename)
  Rack::Test::UploadedFile.new(file)
end

def rack_theme_image(filename)
  file = FixturedAsset.open(File.join('..', 'images', filename))
  Rack::Test::UploadedFile.new(file)
end
