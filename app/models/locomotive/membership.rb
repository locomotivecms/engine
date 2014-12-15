module Locomotive
  class Membership

    include Locomotive::Mongoid::Document

    ROLES = %w(author designer admin)

    ## fields ##
    field :role, default: 'author'

    ## associations ##
    belongs_to  :account, class_name: 'Locomotive::Account', validate: false
    embedded_in :site,    class_name: 'Locomotive::Site',    inverse_of: :memberships

    ## validations ##
    validates_presence_of :account
    validate              :account_is_unique

    ## virtual attributes ##
    attr_accessor :email

    ## callbacks ##
    before_save :define_role

    ## methods ##

    ROLES.each do |_role|
      define_method("#{_role}?") do
        self.role == _role
      end
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

    def define_role
      self.role = ROLES.include?(role.downcase) ? role.downcase : ROLES.first
    end

  end
end
