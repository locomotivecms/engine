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
          # before_rearrange  :foo #propagate_fullpath_changes
          # after_save        :propagate_fullpath_changes

          ## scopes ##
          # scope :fullpath, lambda { |fullpath| { :where => { :fullpath => fullpath } } } # used ?

          ## virtual attributes ##
          attr_accessor :wildcards_map

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
          !self.fullpath.try(:index, '*').nil?
        end

        # It returns a pretty output of the fullpath. The "*" characters
        # are replaced by the following pattern ":<slug>" like you can find
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

        protected

        def get_wildcards_from_parent
          return true if self.parent.nil?

          if self.parent.has_wildcards?
            puts "[get_wildcards_from_parent] #{self.slug} - #{self.parent.wildcards.inspect}"
            self.wildcards  = self.parent.wildcards
          elsif !self.wildcard?
            self.wildcards  = nil
          end

          true
        end

        def add_slug_to_wildcards
          (self.wildcards ||= []) << self.slug if self.wildcard?
        end

        def build_fullpath
          if self.index? || self.not_found?
            self.fullpath = self.slug
          else
            slugs = self.ancestors_and_self.map { |page| page.wildcard? ? '*' : page.slug }
            slugs.shift unless slugs.size == 1
            self.fullpath = File.join slugs.compact
          end
        end

        def propagate_fullpath_changes
          return true unless self.wildcard_changed? || self.slug_changed?

          parent_identities = { self._id => self }

          Rails.logger.debug "[propagate_fullpath_changes] BEGIN page #{self.slug} #{self.fullpath} / #{self.wildcards.inspect} / #{self._parent.try(:has_wildcards?).inspect}"
          puts "[propagate_fullpath_changes] BEGIN page #{self.slug} #{self.fullpath} / #{self.wildcards.inspect} / #{self._parent.try(:has_wildcards?).inspect}"

          self.descendants.order_by([[:depth, :asc]]).each do |page|
            _parent     = parent_identities[page.parent_id]
            _fullpath   = {}
            _wildcards  = nil

            puts "[propagate_fullpath_changes] #{page.fullpath} / #{page.wildcards.inspect} / #{page._parent.try(:has_wildcards?).inspect}"

            if _parent.has_wildcards?
              _wildcards = _parent.wildcards + (page.wildcard? ? [page.slug] : [])
            end

            self.site.locales.each do |locale|
              base_fullpath = _parent.fullpath_translations[locale]
              slug          = page.wildcard? ? '*' : page.slug_translations[locale]

              next if base_fullpath.blank?

              _fullpath[locale] = File.join(base_fullpath, slug)
            end

            selector    = { 'id' => page._id }
            operations  = {
              '$set' => {
                'wildcards'       => _wildcards,
                'fullpath'        => _fullpath
              }
            }
            self.collection.update selector, operations

            parent_identities[page._id] = page
          end
        end

      end
    end
  end
end
