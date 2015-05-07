module Locomotive
  module API
    module Forms

      class PageForm < BaseForm

        attrs :name, :title, :slug, :handle, :response_type, :published

        # Tree
        attrs :parent_id, :position, :listed

        # Template
        attrs :is_layout, :allow_layout, :template

        # Redirection
        attrs  :redirect, :redirect_url, :redirect_type

        # Templatized
        attrs :templatized, :target_klass_slug

        # SEO
        attrs :seo_title, :meta_keywords, :meta_description

        # Editable elements
        attrs :editable_elements_attributes

        def initialize(attributes = {}, existing_page = nil)
          @existing_page = existing_page
          super(attributes)
        end

        ## Custom setters ##

        def editable_elements=(elements)
          self.editable_elements_attributes = elements.map do |attrs|
            if element = @existing_page.try(:find_editable_element, attrs[:block], attrs[:slug])
              attrs[:_id] = element._id
            end

            EditableElementForm.new(attrs).serializable_hash
          end
        end

        def content_type=(value)
          self.templatized = true if value.present?

          self.target_klass_slug = value
        end

        def redirect_url=(value)
          self.redirect = true if value.present?

          set_attribute :redirect_url, value
        end

      end

    end
  end
end
