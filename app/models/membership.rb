class Membership
  
  include Locomotive::Mongoid::Document
  
  ## fields ##
  field :admin, :type => Boolean, :default => false
  
  ## associations ##
  belongs_to_related :account
  embedded_in :site, :inverse_of => :memberships
  
  ## validations ##
  validates_presence_of :account
  
  ## methods ##
  
  def email; @email; end
  
  def email=(email)
    @email = email
    self.account = Account.where(:email => email).first
  end
  
  def action_to_take
    if @email.blank?
      :error
    elsif self.account.nil?
      :create_account
    elsif self.site.memberships.find_all { |m| m.account_id == self.account_id }.size > 1
      :nothing
    else
      :save_it
    end
  end
  
end