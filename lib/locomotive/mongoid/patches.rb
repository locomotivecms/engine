require 'mongoid'

## various patches
module Mongoid #:nodoc:
    
  module Document
  
    def update_child_with_noname(child, clear = false)
      name = child.association_name
      return if name.blank? # fix a weird bug with mongoid-acts-as-tree
      update_child_without_noname(child, clear)
    end
  
    alias_method_chain :update_child, :noname
  
  end
end