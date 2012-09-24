module Locomotive
  class Configuration

    @@defaults = {
      :name                   => 'LocomotiveApp',
      :domain                 => 'example.com',
      :reserved_subdomains    => %w{www admin email blog webmail mail support help site sites},
      # :forbidden_paths      => %w{layouts snippets stylesheets javascripts assets admin system api},
      :reserved_slugs         => %w{stylesheets javascripts assets admin locomotive images api pages edit},
      :locales                => %w{en de fr pt-BR it nl nb es ru et},
      :site_locales           => %w{en de fr pt-BR it nl nb es ru et},
      :cookie_key             => '_locomotive_session',
      :enable_logs            => false,
      :delayed_job            => false,
      :default_locale         => :en,
      :mailer_sender          => 'support@example.com',
      :manage_subdomain       => false,
      :manage_manage_domains  => false,
      :ui                     => {
        :latest_entries_nb    => 5,
        :max_content_types    => 2
      },
      :rack_cache             => {
        :verbose     => true,
        :metastore   => URI.encode("file:#{Rails.root}/tmp/dragonfly/cache/meta"), # URI encoded in case of spaces
        :entitystore => URI.encode("file:#{Rails.root}/tmp/dragonfly/cache/body")
      },
      :devise_modules             => [:rememberable, :database_authenticatable, :token_authenticatable, :recoverable, :trackable, :validatable, :encryptable, { :encryptor => :sha1 }],
      :context_assign_extensions  => { },
      :models_for_templatization  => [],
      :csrf_protection            => false
    }

    cattr_accessor :settings

    def initialize
      @@settings = self.class.get_from_hash(@@defaults)
    end

    def self.settings
      @@settings
    end

    def multi_sites?
      self.multi_sites != false
    end

    def manage_subdomain?
      self.manage_subdomain == true
    end

    def manage_domains?
      self.manage_domains == true
    end

    def manage_subdomain_n_domains?
      self.manage_subdomain? && self.manage_domains?
    end

    def reserved_subdomains
      if self.multi_sites?
        if self.multi_sites.reserved_subdomains.blank?
          @@defaults[:reserved_subdomains]
        else
          self.multi_sites.reserved_subdomains
        end
      else
        []
      end
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
      if block_given?
        self.delete(key) unless super(key).respond_to?(:keys)
        yield(super(key))
      else
        super(key)
      end

      # block_given? ? yield(super(key)) : super(key)
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
