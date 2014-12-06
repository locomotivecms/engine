# require 'singleton'

# module Locomotive
#   class PolicyRegistry
#     include Singleton

#     def initialize
#       @policies = Hash.new
#     end

#     def [] klass
#       @policies[klass]
#     end

#     def []= klass, policy
#       @policies[klass] = policy
#     end
#   end
# end
