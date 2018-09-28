module Locomotive
  module API
    module Forms

      class PageForm < BaseForm

        attrs :title, :slug, :handle, :response_type, :published, :cache_enabled

        # Tree
        attrs :parent_id, :position, :listed

        # Template
        attrs :is_layout, :allow_layout, :raw_template

        # Redirection
        attrs  :redirect, :redirect_url, :redirect_type

        # Templatized
        attrs :templatized, :target_klass_slug

        # SEO
        attrs :seo_title, :meta_keywords, :meta_description

        # Editable elements
        attrs :editable_elements_attributes

        # Sections
        attrs :sections_content, :sections_dropzone_content

        # Display settings
        attrs :display_settings

        def initialize(site, attributes = {}, existing_page = nil)
          @site = site
          @existing_page = existing_page
          super(attributes)
        end

        ## Custom setters ##

        def parent=(id_or_path)
          self.parent_id = @site.pages.by_id_or_fullpath(id_or_path).pluck(:_id).first
        end

        def template=(template)
          self.raw_template = template
        end

        def editable_elements=(elements)
          self.editable_elements_attributes = elements.map do |attrs|
            if element = @existing_page.try(:find_editable_element, attrs[:block], attrs[:slug])
              attrs[:_id] = element._id
            end

            EditableElementForm.new(attrs).serializable_hash
          end
        end

        def sections_content=(value)
          set_attribute(:sections_content, JSON.parse(value))
        end

        def sections_dropzone_content=(value)
          set_attribute(:sections_dropzone_content, JSON.parse(value))
        end

        def content_type=(value)
          self.templatized = true if value.present?

          self.target_klass_slug = value
        end

        def redirect_url=(value)
          self.redirect = true if value.present?

          set_attribute :redirect_url, value
        end

        def display_settings=(settings)
          (settings || {}).each do |k, v|
            settings[k] = v == 'true'
          end
          set_attribute(:display_settings, settings)
        end

      end

    end
  end
end
