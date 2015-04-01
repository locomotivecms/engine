module Locomotive
  class PageForm < BaseForm

    attrs :name, :title, :slug, :parent_id, :parent_fullpath, :position, :handle,
          :response_type, :cache_strategy, :redirect, :redirect_url, :redirect_type,
          :listed, :published, :templatized, :is_layout, :allow_layout,
          :templatized_from_parent, :fullpath, :localized_fullpaths, :depth,
          :template_changed, :translated_in, :seo_title, :meta_keywords,
          :meta_description, :target_klass_slug

    #  target_klass_name and target_entry_name are aliases
    attr_accessor :target_klass_name, :target_entry_name

    def target_klass_name=(val)
      target_klass_name_will_change! unless target_klass_name == val
      @target_klass_name = val
    end

    def target_entry_name=(val)
      target_entry_name_will_change! unless target_entry_name == val
      @target_entry_name = val
    end

  end
end
