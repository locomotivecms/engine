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
        PolicyRegistry.instance[role_name] = role
      end

      def authorized? user, action, resource, membership
        role = membership.to_role
        policies = PolicyRegistry.instance[role].policies
        policy = policies[resource]
        policy.send(:"#{action}?", user, resource, membership)
      rescue
        false
      end

      def scope user, site, resource, membership
        role = membership.to_role
        scopes = PolicyRegistry.instance[role].scopes
        scope = scopes[resource]
        scope.resolve user, site, membership
      rescue
        []
      end

    end
  end
end
