module Locomotive
  class PageEntity < BaseEntity

    expose  :title, :slug, :parent_id, :parent_fullpath, :position, :handle,
    :response_type, :cache_strategy, :redirect, :redirect_url, :redirect_type,
    :listed, :published, :templatized, :is_layout, :allow_layout,
    :templatized_from_parent, :target_klass_slug, :target_klass_name,
    :target_entry_name, :raw_template, :escaped_raw_template, :seo_title,
    :meta_keywords, :meta_description, :fullpath, :localized_fullpaths, :depth,
    :template_changed, :translated_in

    expose :editable_elements, using: Locomotive::EditableElementEntity

  end
end
