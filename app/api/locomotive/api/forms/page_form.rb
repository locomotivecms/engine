module Locomotive
  module API
    module Forms

      class PageForm < BaseForm

        attrs :name, :title, :slug, :parent_id, :position, :handle,
              :response_type, :is_layout, :allow_layout,
              :redirect, :redirect_url, :redirect_type,
              :listed, :published, :templatized, :content_type,
              :seo_title, :meta_keywords,
              :editable_elements

        def redirect
          puts @redirect_url.inspect
          @redirect_url.present?
        end

      end

    end
  end
end
