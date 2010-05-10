class Account
  include Mongoid::Document
  include Mongoid::Timestamps  
  
  # devise modules
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable

  # attr_accessible :email, :password, :password_confirmation # TODO
  
  ## attributes ##
  field :name
  field :locale, :default => 'en'
  
  ## validations ##
  validates_presence_of :name
  
  ## associations ##
  
  ## callbacks ##  
  before_destroy :remove_memberships!
  
  ## methods ##
  
  def sites
    Site.where({ 'memberships.account_id' => self._id })
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
