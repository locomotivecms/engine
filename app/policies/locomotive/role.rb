module Locomotive
  class Role
    attr_reader :role, :policies, :scopes

    def initialize(role, &blk)
      @policies, @scopes = {}, {}
      instance_eval(&blk) if block_given?
    end

    def policy(klass, &blk)
      if block_given?
        policy = Policy.new(klass, &blk)
        @policies[klass] = policy
      end
    end

    def scope(klass, &blk)
      if block_given?
        scope = Scope.new(klass, &blk)
        @scopes[klass] = scope
      end
    end
  end
end
