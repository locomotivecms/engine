module Locomotive
  module Extensions
    module Page
      module Templatized

        extend ActiveSupport::Concern

        included do

          ## fields ##
          field :templatized,             type: Boolean, default: false
          field :templatized_from_parent, type: Boolean, default: false
          field :target_klass_name

          ## validations ##
          validates_presence_of :target_klass_name, if: :templatized?
          validate              :ensure_target_klass_name_security

          ## callbacks ##
          before_validation :get_templatized_from_parent
          before_validation :ensure_target_klass_name_security
          before_validation :set_slug_if_templatized
          after_save        :propagate_templatized

          ## scopes ##
          scope :templatized, where(templatized: true)

          ## virtual attributes ##
          attr_accessor :content_entry
        end

        # Return the content type specified by the target_klass_name property.
        #
        # @return [ Object ] The content type or nil if not found
        #
        def content_type
          if self.target_klass_name =~ /^Locomotive::ContentEntry([a-z0-9]+)$/
            @content_type ||= self.site.content_types.find($1) rescue nil
          else
            nil
          end
        end

        # Return the class specified by the target_klass_name property
        #
        # @example
        #
        #   page.target_klass_name = 'Locomotive::ContentEntry12345'
        #   page.target_klass # <Locomotive::ContentEntry12345...>
        #
        # @return [ Class ] The target class
        #
        def target_klass
          target_klass_name.constantize
        end

        # Return the slug related to the target_klass.
        # In other words, it returns the slug of the target content type.
        #
        # @return [ String ] The slug of the target class / content type. Nil if no target klass matching a content type
        #
        def target_klass_slug
          self.content_type.try(:slug)
        end

        # Set the target klass from the slug of a content type
        #
        # @param [ String ] slug The slug of the content type
        #
        # @return [ Object ] The content type or nil if not found
        #
        def target_klass_slug=(slug)
          if @content_type = self.site.content_types.where(slug: slug).first
            self.target_klass_name = @content_type.entries_class_name
          end
          @content_type
        end

        # Give the name which can be used in a liquid template in order
        # to reference an entry. It uses the slug property if the target klass
        # is a Locomotive content type or the class name itself for the other classes.
        #
        # @example
        #
        #   page.target_klass_name = 'Locomotive::ContentEntry12345' # related to the content type Articles
        #   page.target_entry_name = 'article'
        #
        #   page.target_klass_name = 'OurProduct'
        #   page.target_entry_name = 'our_product'
        #
        # @return [ String ] The name in lowercase and underscored
        #
        def target_entry_name
          if self.content_type
            self.content_type.slug.singularize
          else
            self.target_klass_name.underscore
          end
        end

        # Find the entry both specified by the target klass and identified by the permalink
        #
        # @param [ String ] permalink The permalink of the entry
        #
        # @return [ Object ] The document
        #
        def fetch_target_entry(permalink)
          target_klass.find_by_permalink(permalink)
        end

        # Find all the ordered entries of the target klass filtered or not
        # by the conditions passed in parameter.
        #
        # @param [ Hash ] conditions The conditions used to filter the entries (optional)
        #
        # @return [ Object ] The documents
        #
        def fetch_target_entries(conditions = {})
          if self.content_type
            self.content_type.ordered_entries(conditions)
          else
            []
          end
        end

        protected

        def get_templatized_from_parent
          return if self.parent.nil?

          if self.parent.templatized?
            self.templatized        = self.templatized_from_parent = true
            self.target_klass_name  = self.parent.target_klass_name
          elsif !self.templatized?
            self.templatized        = self.templatized_from_parent = false
            self.target_klass_name  = nil
          end
        end

        def set_slug_if_templatized
          self.slug = 'content_type_template' if self.templatized? && !self.templatized_from_parent?
        end

        # Make sure the target_klass is owned by the site OR
        # if it belongs to the models allowed by the application
        # thanks to the models_for_templatization option.
        #
        def ensure_target_klass_name_security
          return if !self.templatized? || self.target_klass_name.blank?

          if self.target_klass_name =~ /^Locomotive::ContentEntry([a-z0-9]+)$/
            content_type = Locomotive::ContentType.find($1)

            if content_type.site_id != self.site_id
              self.errors.add :target_klass_name, :security
            end
          elsif !Locomotive.config.models_for_templatization.include?(self.target_klass_name)
            self.errors.add :target_klass_name, :security
          end
        end

        # Set the templatized, templatized_from_parent properties of
        # the children of the current page ONLY IF the templatized
        # attribute got changed.
        #
        def propagate_templatized
          return unless self.templatized_changed?

          selector = { 'parent_ids' => { '$in' => [self._id] } }
          operations  = {
            '$set' => {
              'templatized'             => self.templatized,
              'templatized_from_parent' => self.templatized,
              'target_klass_name'       => self.target_klass_name
            }
          }

          self.collection.find(selector).update(operations, multi: true)
        end

      end
    end
  end
end
