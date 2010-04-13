class Account
  include Mongoid::Document
  include Mongoid::Timestamps  
  
  # devise modules
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable

  # attr_accessible :email, :password, :password_confirmation # TODO
  
  ## attributes ##
  field :name
  field :locale, :default => 'en'
  
  ## validations ##
  validates_presence_of :name
  
  ## associations ##
  
  def sites
    Site.where({ :account_ids => self._id })
  end
  
end
