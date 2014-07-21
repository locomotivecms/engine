module Locomotive
  class Role
    attr_reader :role, :policies

    def initialize(role, &blk)
      @policies = {}
      instance_eval(&blk) if block_given?
    end

    def policy(klass, &blk)
      if block_given?
        policy = Policy.new(klass, &blk)
        @policies[klass] = policy
      end
    end
  end
end
