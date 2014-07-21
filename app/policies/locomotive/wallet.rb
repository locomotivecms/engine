module Locomotive
  class Wallet

    def initialize &blk
      instance_eval(&blk) if block_given?
    end

    def role(role_name, &blk)
      if block_given?
        role = Role.new(role_name, &blk)
        Wallet[role_name] = role
      end
    end

    class << self

      def generate_policy_for &block
        Wallet.new &block
      end

      def [] role_name
        PolicyRegistry.instance[role_name]
      end

      def []= role_name, role
        Locomotive::PolicyRegistry.instance[role_name] = role
      end

      def authorized? user, resource, action, membership
        role = user.to_role
        policies = PolicyRegistry.instance[role].policies
        klass = resource.class.name.downcase.to_sym
        policy = policies[klass]
        policy.send(:"#{action}?", user, resource, membership)
      rescue
        false
      end
    end
  end
end
