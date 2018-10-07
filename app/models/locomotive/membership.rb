module Locomotive
  class Membership

    include Locomotive::Mongoid::Document
    include Concerns::Membership::Role

    ROLES = %w(author designer admin)

    ## associations ##
    belongs_to  :account, class_name: 'Locomotive::Account', validate: false
    embedded_in :site,    class_name: 'Locomotive::Site',    inverse_of: :memberships
    belongs_to  :role,    class_name: 'Locomotive::Role', validate: false

    ## validations ##
    validates_presence_of :account
    validate              :account_is_unique
    validates_presence_of :role_id
    ## virtual attributes ##
    attr_accessor :email

    ## methods ##

    ROLES.each do |_role|
      define_method("#{_role}?") do
        self.role_name == _role
      end
    end

    def is_admin?
        self.role.try(:name) == 'admin'
    end

    def to_role
      self.role.to_sym
    end

    protected

    def account_is_unique
      if self.site.memberships.where(account_id: self.account_id).count > 1
        [:email, :account].each do |attribute|
          self.errors.add(attribute, :unique_account)
        end
      end
    end

  end
end
