# module Locomotive
#   class Scope
#     attr_reader :klass, :rule

#     def initialize(klass, &rule)
#       @klass = klass
#       @rule = rule
#     end

#     def resolve user, site, membership
#       # raise Exception.new('Should be a Site') unless site.is_a?(Locomotive::Site)
#       rule.call user, site, membership
#     end
#   end
# end
