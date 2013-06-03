module Locomotive
  class Account

    include Locomotive::Mongoid::Document

    devise *Locomotive.config.devise_modules

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

    ## attributes ##
    field :name
    field :locale,  default: Locomotive.config.default_locale.to_s or 'en'
    field :api_key

    ## protected attributes ##
    attr_protected :api_key

    ## validations ##
    validates_presence_of :name

    ## associations ##

    ## callbacks ##
    before_validation :api_key_should_not_be_empty
    before_destroy    :remove_memberships!

    ## scopes ##
    scope :ordered, order_by(name: :asc)

    ## indexes ##
    index({ email: 1 }, { unique: true, background: true })

    ## methods ##

    def sites
      @sites ||= Site.where('memberships.account_id' => self._id)
    end

    # Tell if the account has admin privileges or not.
    # Actually, an account is considered as an admin if
    # it owns at least one admin membership in all its sites.
    #
    # @return [ Boolean ] True if admin
    #
    def admin?
      Site.where(memberships: { '$elemMatch' => { account_id: self._id, role: :admin } }).count > 0
    end

    # Regenerate the API key without saving the account.
    #
    # @return [ String ] The new api key
    #
    def regenerate_api_key
      self.api_key = Digest::SHA1.hexdigest("#{self._id}-#{Time.now.to_f}-#{self.created_at}")
    end

    # Regenerate the API key AND then save the account.
    #
    def regenerate_api_key!
      self.regenerate_api_key
      self.save
    end

    # Create the API token which will be passed to all the requests to the Locomotive API.
    # It requires the credentials of an account with admin role OR the API key of the site.
    # If an error occurs (invalid account, ...etc), this method raises an exception that has
    # to be caught somewhere.
    #
    # @param [ Site ] site The site where the authentication request is made
    # @param [ String ] email The email of the account
    # @param [ String ] password The password of the account
    # @param [ String ] api_key The API key of the site.
    #
    # @return [ String ] The API token
    #
    def self.create_api_token(site, email, password, api_key)
      if api_key.present?
        account = self.where(api_key: api_key).first

        raise 'The API key is invalid.' if account.nil?
      elsif email.present? && password.present?
        account = self.where(email: email.downcase).first

        raise 'Invalid email or password.' if account.nil? || !account.valid_password?(password)
      else
        raise 'The request must contain either the user email and password OR the API key.'
      end

      account.ensure_authentication_token!

      account.authentication_token
    end

    # Logout the user responding to the token passed in parameter from the API.
    # An exception is raised if no account corresponds to the token.
    #
    # @param [ String ] token The API token created by the create_api_token method.
    #
    # @return [ String ] The API token
    #
    def self.invalidate_api_token(token)
      account = self.where(authentication_token: token).first

      raise 'Invalid token.' if account.nil?

      account.reset_authentication_token!

      token
    end

    def devise_mailer
      Locomotive::DeviseMailer
    end

    protected

    def api_key_should_not_be_empty
      if self.api_key.blank?
        self.regenerate_api_key
      end
    end

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
