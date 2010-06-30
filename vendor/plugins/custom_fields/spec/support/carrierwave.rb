require 'carrierwave/test/matchers'

CarrierWave.configure do |config|
  config.storage = :file
  config.store_dir = "uploads"
  config.cache_dir = "cache"
  config.root = File.join(File.dirname(__FILE__), '..', 'tmp')
end

module FixturedFile
  def self.open(filename)
    File.new(self.path(filename))
  end
  
  def self.path(filename)
    File.join(File.dirname(__FILE__), '..', 'fixtures', filename)
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

FixturedFile.reset!