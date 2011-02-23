module Locomotive
  class Configuration

    @@defaults = {
      :name             => 'LocomotiveApp',
      :default_domain   => 'example.com',
      :reserved_subdomains => %w{www admin email blog webmail mail support help site sites},
      # :forbidden_paths  => %w{layouts snippets stylesheets javascripts assets admin system api},
      :reserved_slugs   => %w{stylesheets javascripts assets admin images api pages edit},
      :locales          => %w{en de fr pt-BR},
      :cookie_key       => '_locomotive_session',
      :enable_logs      => false,
      :heroku           => false,
      :delayed_job      => true,
      :default_locale   => :en,
      :mailer_sender    => 'support@example.com'
    }

    cattr_accessor :settings

    def initialize
      @@settings = self.class.get_from_hash(@@defaults)
    end

    def self.settings
      @@settings
    end

    def method_missing(name, *args, &block)
      self.settings.send(name, *args, &block)
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
