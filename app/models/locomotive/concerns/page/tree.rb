module Locomotive
  module Concerns
    module Page
      module Tree

        extend ActiveSupport::Concern

        included do
          include ::Mongoid::Tree
          include ::Mongoid::Tree::Ordering
          prepend PatchedTreeMethods

          ## fields ##
          field :depth, type: Integer, default: 0

          ## callbacks ##
          before_save     :persist_depth
          before_save     :ensure_index_position
          before_destroy  :destroy_children

          ## scopes ##
          scope :order_by_depth_and_position, -> { order_by(:depth.asc, :position.asc) }

          ## indexes ##
          index site_id:  1, depth:    1, position: 1
          index depth:    1, position: 1
          index position: 1
        end

        module PatchedTreeMethods

          def ancestors
            # https://github.com/benhutton/mongoid-tree/commit/acb6eb0440dc003cd8536cb8cc6ff4b16c9c9402
            super.order_by(:depth.asc)
          end

          ##
          # Returns this document's siblings and itself, all scoped by the site
          #
          # @return [Mongoid::Criteria] Mongoid criteria to retrieve the document's siblings and itself
          def siblings_and_self
            base_class.where(parent_id: self.parent_id, site_id: self.site_id)
          end

          private

          def assign_default_position
            return if self.position.present? && !self.persisted?
            super
          end

          protected

          def rearrange_children
            self.children.reset
            super
          end

        end

        # Returns the children of this node but with the minimal set of required attributes
        #
        # @return [ Array ] The children pages ordered by their position
        #
        def children_with_minimal_attributes(attrs = [])
          self.children.minimal_attributes(attrs)
        end

        # Assigns the new position of each child of this node.
        #
        # @param [ Array ] ids The ordered list of page ids (string)
        #
        def sort_children!(ids)
          position, cached_children = 0, self.children.to_a
          ids.each do |id|
            if child = cached_children.detect { |p| p._id == BSON::ObjectId.from_string(id) }
              child.position = position
              child.save
              position += 1
            end
          end
        end

        def depth
          self.parent_ids.count
        end

        protected

        def persist_depth
          self.depth = self.parent_ids.count
        end

        def ensure_index_position
          self.position = 0 if self.index?
        end

      end
    end
  end
end
