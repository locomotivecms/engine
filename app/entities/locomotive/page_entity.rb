module Locomotive
  class PageEntity < BaseEntity

    expose  :title, :slug, :parent_id, :position, :handle,
    :response_type, :cache_strategy, :redirect, :redirect_url, :redirect_type,
    :listed, :published, :templatized, :is_layout, :allow_layout,
    :templatized_from_parent, :target_klass_slug, :target_klass_name,
    :raw_template, :seo_title, :meta_keywords,
    :meta_description, :fullpath, :depth, :template_changed,
    :translated_in

    expose :editable_elements, using: Locomotive::EditableElementEntity

  end
end
