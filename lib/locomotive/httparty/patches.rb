# require 'crack/json'
#
# module Crack
#   class JSON
#
#     def self.parse_with_tumblr(json)
#       cleaned_json = json.gsub(/^var\s+.+\s+=\s+/, '').gsub(/;$/, '')
#       parse_without_tumblr(cleaned_json)
#     rescue ArgumentError => e
#       raise ParseError, "Invalid JSON string #{e.inspect}"
#     end
#
#     class << self
#       alias_method_chain :parse, :tumblr
#     end
#
#   end
# end
