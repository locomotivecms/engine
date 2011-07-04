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

module FixturedTheme
  def self.open(filename)
    File.new(self.path(filename))
  end

  def self.path(filename)
    File.join(File.dirname(__FILE__), '..', 'fixtures', 'themes', filename)
  end

  def self.duplicate(filename)
    dst = File.join(File.dirname(__FILE__), '..', 'tmp', filename)
    FileUtils.cp self.path(filename), dst
    dst
  end

  def self.duplicate_and_open(filename)
    File.open(self.duplicate(filename))
  end
end

FixturedAsset.reset!
