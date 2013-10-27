module Locomotive
  class Membership

    include Locomotive::Mongoid::Document

    ## fields ##
    field :role, default: 'author'

    ## associations ##
    belongs_to  :account, class_name: 'Locomotive::Account', validate: false
    embedded_in :site,    class_name: 'Locomotive::Site',    inverse_of: :memberships

    ## validations ##
    validates_presence_of :account
    validate              :can_change_role, if: :role_changed?

    ## callbacks ##
    before_save :define_role

    ## methods ##

    Locomotive::Ability::ROLES.each do |_role|
      define_method("#{_role}?") do
        self.role == _role
      end
    end

    def email; @email; end

    def email=(email)
      @email = email
      self.account = Locomotive::Account.where(email: email).first
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
      @ability ||= Locomotive::Ability.new(self.account, self.site)
    end

    protected

    def define_role
      self.role = Locomotive::Ability::ROLES.include?(role.downcase) ? role.downcase : Locomotive::Ability::ROLES.first
    end

    # Users should not be able to set the role of another user to be higher than
    # their own. A designer for example should not be able to set another user to
    # be an administrator
    def can_change_role
      current_site       = Thread.current[:site]
      current_membership = current_site.memberships.where(account_id: Thread.current[:account].id).first if current_site.present?

      if current_membership.present?
        # The role cannot be set higher than the current one (we use the index in
        # the roles array to check role presidence)
        errors.add(:role, :invalid) if Locomotive::Ability::ROLES.index(role) < Locomotive::Ability::ROLES.index(current_membership.role)
      end
    end

  end
end
