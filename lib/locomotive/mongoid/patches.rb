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

# http://github.com/emk/mongoid/blob/503e346b1b7b250d682a12332ad9d5872f1575e6/lib/mongoid/atomicity.rb
module Mongoid #:nodoc:
  module Atomicity #:nodoc:
    extend ActiveSupport::Concern

    def _updates
      processed = {}

      _children.inject({ "$set" => _sets, "$pushAll" => {}, :other => {} }) do |updates, child|
        changes = child._sets
        updates["$set"].update(changes)
        unless changes.empty?
          processed[child._conficting_modification_key] = true
        end

        # MongoDB does not allow "conflicting modifications" to be
        # performed in a single operation.  Conflicting modifications are
        # detected by the 'haveConflictingMod' function in MongoDB.
        # Examination of the code suggests that two modifications (a $set
        # and a $pushAll, for example) conflict if (1) the key paths being
        # modified are equal or (2) one key path is a prefix of the other.
        # So a $set of 'addresses.0.street' will conflict with a $pushAll
        # to 'addresses', and we will need to split our update into two
        # pieces.  We do not, however, attempt to match MongoDB's logic
        # exactly.  Instead, we assume that two updates conflict if the
        # first component of the two key paths matches.
        if processed.has_key?(child._conficting_modification_key)
          target = :other
        else
          target = "$pushAll"
        end

        child._pushes.each do |attr, val|
          if updates[target].has_key?(attr)
            updates[target][attr] << val
          else
            updates[target].update({attr => [val]})
          end
        end
        updates
      end.delete_if do |key, value|
        value.empty?
      end
    end

    protected
    # Get the key used to check for conflicting modifications.  For now, we
    # just use the first component of _path, and discard the first period
    # and everything that follows.
    def _conficting_modification_key
      _path.sub(/\..*/, '')
    end
  end
end