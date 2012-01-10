module Locomotive
  module Extensions
    module Site
      module I18n

        extend ActiveSupport::Concern

        included do

          ## fields ##
          field :locales, :type => 'RawArray', :default => []

          ## callbacks ##
          # after_validation :add_missing_locales_for_all_pages

        end

        module InstanceMethods

          def locales=(array)
            array = [] if array.blank?; super(array)
          end

          def default_locale
            self.locales.first || Locomotive.config.site_locales.first
          end

          # protected
          #
          # def add_missing_locales_for_all_pages
          #   if self.locales_changed?
          #     list = self.pages.to_a
          #
          #     while !list.empty? do
          #       page = list.pop
          #       begin
          #         page.send(:set_slug_and_fullpath_for_all_locales, self.locales)
          #
          #         page.save
          #
          #       rescue TypeError => e
          #         list.insert(0, page)
          #       end
          #     end
          #   end
          # end

        end

      end
    end
  end
end