# module Locomotive
#   class Right
#     attr_reader :action, :rule
#     def initialize(action, &rule)
#       @action = action
#       @rule = rule
#     end

#     def authorized? user, record, membership
#       self.rule.call user, record, membership
#     end

#   end
# end
