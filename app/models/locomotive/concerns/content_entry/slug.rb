module Locomotive
  module Concerns
    module ContentEntry
      module Slug

        extend ActiveSupport::Concern

        included do

          ## callbacks ##
          before_validation :set_slug

        end

        protected

        # Set the slug of the instance by using the value of the highlighted field
        # (if available). If a sibling content instance has the same permalink then a
        # unique one will be generated
        def set_slug
          self._slug = self._label.dup if self._slug.blank? && self._label.present?

          if self._slug.present?
            # we can't rely on the self.site property yet (brand new entry for instance)
            if self.content_type.site.allow_dots_in_slugs?
              self._slug.pathify!
            else
              self._slug.permalink!
            end

            self.find_next_unique_slug if self.slug_already_taken?
          end

          # all the site locales share the same slug ONLY IF the entry is not localized.
          self.set_same_slug_for_all_site_locales if !self.localized?
        end
        
        # For each locale of the site, we set the slug
        # coming from the value for the default locale.
        def set_same_slug_for_all_site_locales
          return unless self.set_site.localized?

          default_slug = self._slug

          self.set_site.locales.each do |locale|
            ::Mongoid::Fields::I18n.with_locale(locale) do
              self._slug = default_slug
            end
          end
        end

        # Find the next available unique slug as a string
        # and replace the current _slug.
        def find_next_unique_slug
          _index  = 0
          _base   = self._slug.gsub(/-\d+$/, '')

          if _similar = similar_slug(_base)
            _index = _similar.scan(/-(\d+)$/).flatten.last.to_i
          end

          loop do
            _index += 1
            self._slug = [_base, _index].join('-')
            break unless self.slug_already_taken?
          end
        end

        def similar_slug(slug)
          _last_slug = self.class.where(_slug: /^#{slug}-?\d*$/i)
                    .excludes(_id: self._id)
                    .order_by(:created_at.desc)
                    .pluck(:_slug)
                    .first

          if _last_slug
            _last_slug[::Mongoid::Fields::I18n.locale.to_s]
          else
            nil
          end
        end

        def slug_already_taken?
          self.class.where(_slug: self._slug).excludes(_id: self._id).any?
        end

      end
    end
  end
end
