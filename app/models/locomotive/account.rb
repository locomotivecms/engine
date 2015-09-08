module Locomotive
  class Account

    include Locomotive::Mongoid::Document
    devise *Locomotive.config.devise_modules
    acts_as_token_authenticatable
    include Locomotive::Concerns::Account::DevisePatch
    include Locomotive::Concerns::Account::ApiKey

    ## devise fields (need to be declared since 2.x) ##
    field :remember_created_at,     type: Time
    field :email,                   type: String, default: ''
    field :encrypted_password,      type: String, default: ''
    field :authentication_token,    type: String
    field :reset_password_token,    type: String
    field :reset_password_sent_at,  type: Time
    field :password_salt,           type: String
    field :sign_in_count,           type: Integer, default: 0
    field :current_sign_in_at,      type: Time
    field :last_sign_in_at,         type: Time
    field :current_sign_in_ip,      type: String
    field :last_sign_in_ip,         type: String

    mount_uploader :avatar, PictureUploader, validate_integrity: true

    ## attributes ##
    field :name
    field :locale,  default: Locomotive.config.default_locale.to_s or 'en'
    field :super_admin, type: Boolean, default: false

    ## validations ##
    validates_presence_of :name

    ## associations ##
    has_many :created_sites, class_name: 'Locomotive::Site', validate: false, autosave: false

    ## callbacks ##
    before_destroy :remove_memberships!

    ## scopes ##
    scope :ordered,   -> { order_by(name: :asc) }
    scope :by_email,  ->(email) { where(email: email).first }

    ## indexes ##
    index({ email: 1 }, { unique: true, background: true })

    ## aliases ##
    alias_attribute :api_token, :api_key

    ## methods ##

    def sites
      @sites ||= Site.where('memberships.account_id' => self._id)
    end

    # Tell if the account has admin privileges for one (at least)
    # of his/her sites.
    #
    # @return [ Boolean ] True if admin in one of his/her sites.
    #
    def local_admin?
      Site.where(memberships: { '$elemMatch' => { account_id: self._id, role: :admin } }).count > 0
    end

    # Find the first account matching the email parameter
    #
    # @param [ String ] email The email
    #
    # @return [ Object ] The account or nil (if none)
    #
    def self.find_by_email(email)
      where(email: email).first
    end

    def devise_mailer
      Locomotive::DeviseMailer
    end

    protected

    def password_required?
      !persisted? || !password.blank? || !password_confirmation.blank?
    end

    def remove_memberships!
      self.sites.each do |site|
        membership = site.memberships.where(account_id: self._id).first

        if site.admin_memberships.size == 1 && membership.admin?
          raise ::I18n.t('errors.messages.needs_admin_account')
        else
          membership.destroy
        end
      end
    end

  end
end
