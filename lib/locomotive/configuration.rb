# require 'active_support'

# Custom configuration settings 
# code inspired by http://slateinfo.blogs.wvu.edu/
#
# Example:
#   Locomotive::Configuration.setup do |config|
#     config.title      = "Hello world !!!"
#
#     config.admin do |admin| 
#       admin.per_page 10
#     end
#   end
# 
#   Locomotive::Configuration.admin.per_page # => "10"
# 
#   # some alternate ways to access the settings
#   Locomotive::Configuration.config[:admin][:per_page] # => "10"

module Locomotive

  class Configuration

    DEFAULT_SETTINGS = {
      :default_domain  => 'localhost',
      :forbidden_subdomains => %w{www admin email blog webmail mail support help site sites}
    }

    cattr_accessor :settings

    # creates a new configuration object if
    # necessary
    def self.settings # !> redefine settings
      if @@settings.nil?
        @@settings = self.get_from_hash(DEFAULT_SETTINGS)
      else 
        @@settings
      end
    end

    def self.setup
      block_given? ? yield(self.settings) : self.settings
    end

    # reset settings
    def self.reset
      @@settings = nil
    end

    # returns the current configuration
    # by passing a block you can easily edit the
    # configuration values
    def self.config
      block_given? ? yield(self.settings) : self.settings     
    end

    def self.method_missing(name, *args, &block)
      self.config.send(name, *args, &block)
    end

    protected

    # converts a hash map into a ConfigurationHash
    def self.get_from_hash(hash)
      config = ConfigurationHash.new

      hash.each_pair do |key, value|
        config[key] = value.is_a?(Hash) ? self.get_from_hash(value) : value
      end

      config
    end
  end

  # specialized hash for storing configuration settings
  class ConfigurationHash < Hash
    # ensure that default entries always produce 
    # instances of the ConfigurationHash class
    def default(key=nil)
      include?(key) ? self[key] : self[key] = self.class.new
    end

    # retrieves the specified key and yields it
    # if a block is provided
    def [](key, &block)
      block_given? ? yield(super(key)) : super(key)
    end

    # provides member-based access to keys
    # i.e. params.id === params[:id]
    # note: all keys are converted to symbols
    def method_missing(name, *args, &block)
      if name.to_s.ends_with? '=' 
        send :[]=, name.to_s.chomp('=').to_sym, *args
      else
        send(:[], name.to_sym, &block)
      end    
    end
  end
end
