module Locomotive
  module Concerns
    module Shared
      module SiteScope

        extend ActiveSupport::Concern

        included do

          ## associations ##
          belongs_to :site, class_name: 'Locomotive::Site', validate: false, autosave: false, touch: :true

          ## validations ##
          validates_presence_of :site

          ## indexes ##
          index site_id: 1

          # Redefine the auto-generated method by the Mongoid Touchable module
          # in order to touch another field of the site object.
          def touch_site_after_create_or_destroy
            without_autobuild do
              _site = __send__(:site)
              _site.touch(touch_site_attribute) if _site
            end
          end

        end

        def touch_site_attribute
          nil
        end

      end
    end
  end
end
