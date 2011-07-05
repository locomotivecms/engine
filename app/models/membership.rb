class Membership

  include Locomotive::Mongoid::Document

  ## fields ##
  field :role, :default => 'author'

  ## associations ##
  referenced_in :account, :validate => false
  embedded_in :site, :inverse_of => :memberships

  ## validations ##
  validates_presence_of :account

  ## callbacks ##
  before_save :define_role

  ## methods ##

  Ability::ROLES.each do |_role|
    define_method("#{_role}?") do
      self.role == _role
    end
  end

  def email; @email; end

  def email=(email)
    @email = email
    self.account = Account.where(:email => email).first
  end

  def process!
    if @email.blank?
      self.errors.add_on_blank(:email)
      :error
    elsif self.account.blank?
      :create_account
    elsif self.site.memberships.any? { |m| m.account_id == self.account_id && m._id != self._id }
      self.errors.add(:base, 'Already created')
      :already_created
    else
      self.save
      :save_it
    end
  end

  def ability
    @ability ||= Ability.new(self.account, self.site)
  end

  protected

  def define_role
    self.role = Ability::ROLES.include?(role.downcase) ? role.downcase : Ability::ROLES.first
  end

end
