require 'digest'

class Account

  include Locomotive::Mongoid::Document

  # devise modules
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable

  # attr_accessible :email, :password, :password_confirmation # TODO

  ## attributes ##
  field :name
  field :locale, :default => 'en'
  field :switch_site_token

  ## validations ##
  validates_presence_of :name

  ## associations ##

  ## callbacks ##
  before_destroy :remove_memberships!

  ## methods ##

  def sites
    @sites ||= Site.where({ 'memberships.account_id' => self._id })
  end

  def reset_switch_site_token!
    self.switch_site_token = ActiveSupport::SecureRandom.base64(8).gsub("/", "_").gsub(/=+$/, "")
    self.save
  end

  def self.find_using_switch_site_token(token, age = 1.minute)
    return if token.blank?
    self.where(:switch_site_token => token, :updated_at.gt => age.ago.utc).first
  end

  def self.find_using_switch_site_token!(token, age = 1.minute)
    self.find_using_switch_site_token(token, age) || raise(Mongoid::Errors::DocumentNotFound.new(self, token))
  end

  protected

  def password_required?
    !persisted? || !password.blank? || !password_confirmation.blank?
  end

  def remove_memberships!
    self.sites.each do |site|
      site.memberships.delete_if { |m| m.account_id == self._id }

      if site.admin_memberships.empty?
        raise I18n.t('errors.messages.needs_admin_account')
      else
        site.save
      end
    end
  end

end
