module Locomotive
  module Extensions
    module Page
      module Tree

        extend ActiveSupport::Concern

        included do
          include ::Mongoid::Tree
          include ::Mongoid::Tree::Ordering
          include PatchedTreeMethods

          ## fields ##
          field :depth, type: Integer, default: 0

          ## callbacks ##
          before_save     :persist_depth
          before_save     :ensure_index_position
          before_destroy  :delete_descendants

          ## indexes ##
          index position: 1
          index depth:    1, position: 1
          index site_id:  1, depth:    1, position: 1

          alias_method_chain :rearrange, :identity_map
          alias_method_chain :rearrange_children, :identity_map
          alias_method_chain :siblings_and_self, :scoping
        end

        module PatchedTreeMethods

          def ancestors
            # https://github.com/benhutton/mongoid-tree/commit/acb6eb0440dc003cd8536cb8cc6ff4b16c9c9402
            super.order_by(:depth.asc)
          end

          private

          def assign_default_position
            return if self.position.present? && !self.persisted?
            super
          end

        end

        module ClassMethods

          # Returns the tree of pages from the site with the most minimal amount of queries.
          # This method should only be used for read-only purpose since
          # the mongodb returns the minimal set of required attributes to build
          # the tree.
          #
          # @param [ Locomotive::Site ] site The site owning the pages
          #
          # @return [ Array ] The first array of pages (depth = 0)
          #
          def quick_tree(site, minimal_attributes = true)
            pages = (minimal_attributes ? site.pages.unscoped.minimal_attributes : site.pages.unscoped).order_by(:depth.asc, :position.asc).to_a

            tmp = []

            while !pages.empty?
              tmp << _quick_tree(pages.delete_at(0), pages)
            end

            tmp
          end

          #:nodoc:
          def _quick_tree(current_page, pages)
            i, children = 0, []

            while !pages.empty?
              page = pages[i]

              break if page.nil?

              if page.parent_id == current_page.id
                page = pages.delete_at(i)

                children << _quick_tree(page, pages)
              else
                i += 1
              end
            end

            current_page.instance_variable_set(:@children, children || [])

            current_page
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
          cached_children = self.children.to_a
          ids.each_with_index do |id, position|
            child = cached_children.detect { |p| p._id == Moped::BSON::ObjectId(id) }
            child.position = position
            child.save
          end
        end

        ##
        # Returns this document's siblings and itself, all scoped by the site
        #
        # @return [Mongoid::Criteria] Mongoid criteria to retrieve the document's siblings and itself
        def siblings_and_self_with_scoping
          base_class.where(parent_id: self.parent_id, site_id: self.site_id)
        end

        def depth
          self.parent_ids.count
        end

        protected

        def rearrange_with_identity_map
          ::Mongoid::IdentityMap.clear
          rearrange_without_identity_map
        end

        def rearrange_children_with_identity_map
          self.children.reset
          rearrange_children_without_identity_map
        end

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
