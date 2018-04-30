module Locomotive
  class Configuration

    @@default_locales = %w{en de fr bg cs da el es ca fa-IR fi-FI it ja-JP lt nl pl-PL pt pt-BR ru sv sv-FI uk zh-CN}
    @@site_locales    = @@default_locales + %w{hr et nb sk sl sr}

    @@defaults = {
      name:                         'Locomotive',
      host:                         nil,
      # forbidden_paths:            %w{layouts snippets stylesheets javascripts assets admin system api},
      reserved_site_handles:        %w(sites my_account password sign_in sign_out),
      reserved_slugs:               %w{stylesheets javascripts assets admin locomotive images api pages edit},
      reserved_domains:             [],
      locales:                      @@default_locales,
      site_locales:                 @@site_locales,
      cookie_key:                   '_locomotive_session',
      enable_logs:                  false,
      enable_admin_ssl:             false,
      delayed_job:                  false,
      default_locale:               :en,
      mailer_sender:                'support@example.com',
      unsafe_token_authentication:  false,
      enable_registration:          true,
      ui:                     {
        per_page:     10
      },
      rack_cache:             {
        verbose:      true,
        metastore:    URI.encode("file:#{Rails.root}/tmp/dragonfly/cache/meta"), # URI encoded in case of spaces
        entitystore:  URI.encode("file:#{Rails.root}/tmp/dragonfly/cache/body")
      },
      devise_modules:               [:registerable, :rememberable, :database_authenticatable, :recoverable, :trackable, :validatable, :encryptable, { encryptor: :sha1 }],
      steam_image_resizer_secret:   'please change it'
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

    def respond_to?(name, include_all = false)
      self.settings.keys.include?(name.to_sym) || super
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
