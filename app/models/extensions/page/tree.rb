module Models
  module Extensions
    module Page
      module Tree

        extend ActiveSupport::Concern

        included do
          include Mongoid::Acts::Tree

          ## fields ##
          field :position, :type => Integer

          ## behaviours ##
          acts_as_tree :order => ['position', 'asc']

          ## callbacks ##
          before_validation :reset_parent
          before_save { |p| p.send(:write_attribute, :parent_id, nil) if p.parent_id.blank? }
          before_save :change_parent
          before_create { |p| p.send(:fix_position, false) }
          before_create :add_to_list_bottom
          before_destroy :remove_from_list

          # Fixme (Didier L.): Instances methods are defined before the include itself
          alias :fix_position :hacked_fix_position
          alias :descendants :hacked_descendants
        end

        module InstanceMethods

          def sort_children!(ids)
            ids.each_with_index do |id, position|
              child = self.children.detect { |p| p._id == id }
              child.position = position
              child.save
            end
          end

          def parent=(owner) # missing in acts_as_tree
            @_parent = owner
            self.fix_position(false)
            self.instance_variable_set :@_will_move, true
          end

          def hacked_descendants
            return [] if new_record?
            self.class.all_in(path_field => [self._id]).order_by tree_order
         end

          protected

          def change_parent
            if self.parent_id_changed?
              self.fix_position(false)
              self.add_to_list_bottom
              self.instance_variable_set :@_will_move, true
            end
          end

          def hacked_fix_position(perform_save = true)
            if parent.nil?
              self.write_attribute parent_id_field, nil
              self[path_field] = []
              self[depth_field] = 0
            else
              self.write_attribute parent_id_field, parent._id
              self[path_field] = parent[path_field] + [parent._id]
              self[depth_field] = parent[depth_field] + 1
              self.save if perform_save
            end
          end

          def reset_parent
            if self.parent_id_changed?
              @_parent = nil
            end
          end

          def add_to_list_bottom
            self.position = (::Page.where(:_id.ne => self._id).and(:parent_id => self.parent_id).max(:position) || 0) + 1
          end

          def remove_from_list
            return if (self.site rescue nil).nil?

            ::Page.where(:parent_id => self.parent_id).and(:position.gt => self.position).each do |p|
              p.position -= 1
              p.save
            end
          end

        end
      end
    end
  end
end
