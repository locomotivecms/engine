module Locomotive
  class Account

    include Locomotive::Mongoid::Document

    devise *Locomotive.config.devise_modules

    ## devise fields (need to be declared since 2.x) ##
    field :remember_created_at,     :type => Time
    field :email,                   :type => String, :null => false
    field :encrypted_password,      :type => String, :null => false
    field :authentication_token,    :type => String
    field :reset_password_token,    :type => String
    field :reset_password_sent_at,  :type => Time
    field :password_salt,           :type => String
    field :sign_in_count,           :type => Integer
    field :current_sign_in_at,      :type => Time
    field :last_sign_in_at,         :type => Time
    field :current_sign_in_ip,      :type => String
    field :last_sign_in_ip,         :type => String

    ## attributes ##
    field :name
    field :locale, :default => Locomotive.config.default_locale.to_s or 'en'

    ## validations ##
    validates_presence_of :name

    ## associations ##

    ## callbacks ##
    before_destroy :remove_memberships!

    ## methods ##

    def sites
      @sites ||= Site.where({ 'memberships.account_id' => self._id })
    end

    # Create the API token which will be passed to all the requests to the Locomotive API.
    # It requires the credentials of an account with admin role.
    # If an error occurs (invalid account, ...etc), this method raises an exception that has
    # to be caught somewhere.
    #
    # @param [ Site ] site The site where the authentication request is made
    # @param [ String ] email The email of the account
    # @param [ String ] password The password of the account
    #
    # @return [ String ] The API token
    #
    def self.create_api_token(site, email, password)
      raise 'The request must contain the user email and password.' if email.blank? or password.blank?

      account = self.where(:email => email.downcase).first

      raise 'Invalid email or password.' if account.nil?

      account.ensure_authentication_token!

      if not account.valid_password?(password) # TODO: check admin roles
        raise 'Invalid email or password.'
      end

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
      account = self.where(:authentication_token => token).first

      raise 'Invalid token.' if account.nil?

      account.reset_authentication_token!

      token
    end

    def devise_mailer
      Locomotive::DeviseMailer
    end

    def as_json(options = {})
      Locomotive::AccountPresenter.new(self, options).as_json
    end

    protected

    def password_required?
      !persisted? || !password.blank? || !password_confirmation.blank?
    end

    def remove_memberships!
      self.sites.each do |site|
        membership = site.memberships.where(:account_id => self._id).first

        if site.admin_memberships.size == 1 && membership.admin?
          raise ::I18n.t('errors.messages.needs_admin_account')
        else
          membership.destroy
        end
      end
    end

  end
end
