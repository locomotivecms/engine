module Locomotive
  module Extensions
    module Page
      module Fullpath

        extend ActiveSupport::Concern

        included do

          ## fields ##
          field :fullpath,        :localize => true
          field :wildcard,        :type => Boolean, :default => false
          field :wildcards,       :type => Array

          ## callbacks ##
          before_validation :get_wildcards_from_parent
          before_validation :add_slug_to_wildcards
          before_save       :build_fullpath
          after_update      :propagate_fullpath_changes

          # before_save       :set_children_autosave
          # before_rearrange  :foo #propagate_fullpath_changes
          # after_save        :propagate_fullpath_changes

          # after_save { |p| puts "[after_save] #{p.fullpath} / #{p.wildcards.inspect} / #{p.wildcard?}" }

          ## scopes ##
          # scope :fullpath, lambda { |fullpath| { :where => { :fullpath => fullpath } } } # used ?

          ## virtual attributes ##
          attr_accessor :wildcards_hash

        end

        # def foo
        #   Rails.logger.debug "----> rearranging #{self.slug}.......\n\n"
        #   puts "[rearranging]"
        # end

        # This method returns true if the fullpath is enhanced
        # by wildcards. It is different from the wildcard? method
        # because it includes the ancestors when determining if
        # the current page has wildcards or not.
        #
        def has_wildcards?
          self.wildcard? || !self.fullpath.try(:index, '*').nil?
        end

        # It returns a pretty output of the fullpath. The "*" characters
        # are replaced by the following pattern ":<slug>" like the ones you can find
        # in the Ruby on Rails routes.
        #
        def pretty_fullpath
          return self.fullpath unless self.has_wildcards?

          index = 0

          self.fullpath.split('/').map do |segment|
            if segment == '*'
              ":#{self.wildcards[index]}".tap { index += 1 }
            else
              segment
            end
          end.join('/')
        end

        # It returns the fullpath with wildcard segments replaced by the values
        # specified in the first argument.
        #
        # @param [ Hash ] values The map assigning to a wildcard name its value
        # @return [ String ] The compiled fullpath
        #
        def compiled_fullpath(values)
          return self.fullpath unless self.has_wildcards?

          index = 0

          self.fullpath.split('/').map do |segment|
            if segment == '*'
              "#{values[self.wildcards[index]]}".tap { index += 1 }
            else
              segment
            end
          end.join('/')
        end

        # It builds the map associating the name of a wildcard
        # with its value within the path.
        # The map is also stored in the wildcards_hash attribute
        # of the page.
        #
        # @param [ String ] path the path from the HTTP request
        # @return [ Hash ] The map
        #
        def match_wildcards(path)
          self.wildcards_hash, wildcard_index, segments = {}, 0, self.fullpath.split('/')

          path.split('/').each_with_index do |segment, index|
            if segments[index] == '*'
              self.wildcards_hash[self.wildcards[wildcard_index].underscore] = segment
              wildcard_index += 1
            end
          end

          self.wildcards_hash
        end

        protected

        # def set_children_autosave
        #   @autosave_for_children = !must_propagate_fullpath_changes?
        #   true
        # end

        def get_wildcards_from_parent
          return true if self.parent.nil?

          if self.parent.has_wildcards?
            # puts "[get_wildcards_from_parent] #{self.slug} - #{self.parent.wildcards.inspect}"
            self.wildcards  = self.parent.wildcards.clone
          else
            # puts "[get_wildcards_from_parent] #{self.slug} - reset wildcards"
            self.wildcards  = []
          end
        end

        def add_slug_to_wildcards
          # puts "[add_slug_to_wildcards] #{self.slug} / #{self.wildcard?}"
          (self.wildcards ||= []) << self.slug if self.wildcard?
        end

        def build_fullpath
          if self.index? || self.not_found?
            self.fullpath = self.slug
          else
            segments = (self.parent.fullpath.try(:split, '/') || [nil]) + [self.wildcard? ? '*' : self.slug]
            segments.shift if segments.first == 'index'
            self.fullpath = File.join segments.compact
          end
        end

        def propagate_fullpath_changes
          if self.fullpath_changed? || self.wildcards_changed?
            self.rearrange_children!
          end
        end

        # def must_propagate_fullpath_changes?
        #   self.wildcard_changed? || self.slug_changed?
        # end
        #
        # def propagate_fullpath_changes
        #   return true unless must_propagate_fullpath_changes?
        #
        #   parent_identities = { self._id => self }
        #
        #   Rails.logger.debug "[propagate_fullpath_changes] BEGIN page #{self.slug} #{self.fullpath} / #{self.wildcards.inspect} / #{self._parent.try(:has_wildcards?).inspect}"
        #   puts "[propagate_fullpath_changes] BEGIN page #{self.slug} #{self.fullpath} / #{self.wildcards.inspect} / #{self._parent.try(:has_wildcards?).inspect}"
        #
        #   self.descendants.order_by([[:depth, :asc]]).each do |page|
        #     _parent     = parent_identities[page.parent_id]
        #     _fullpath   = {}
        #     _wildcards  = nil
        #
        #     puts "[propagate_fullpath_changes] #{page.fullpath} / #{page.wildcards.inspect} / #{page._parent.try(:has_wildcards?).inspect}"
        #
        #     if _parent.has_wildcards?
        #       _wildcards = _parent.wildcards + (page.wildcard? ? [page.slug] : [])
        #     end
        #
        #     self.site.locales.each do |locale|
        #       base_fullpath = _parent.fullpath_translations[locale]
        #       slug          = page.wildcard? ? '*' : page.slug_translations[locale]
        #
        #       next if base_fullpath.blank?
        #
        #       _fullpath[locale] = File.join(base_fullpath, slug)
        #     end
        #
        #     selector    = { 'id' => page._id }
        #     operations  = {
        #       '$set' => {
        #         'wildcards'       => _wildcards,
        #         'fullpath'        => _fullpath
        #       }
        #     }
        #     self.collection.update selector, operations
        #
        #     parent_identities[page._id] = page
        #   end
        # end

      end
    end
  end
end
