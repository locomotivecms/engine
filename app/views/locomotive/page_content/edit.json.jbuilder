json.data do
  json.site do
    json.sectionsContent sections_content(current_site, @sections, @section_definitions)
  end

  json.page do
    json.(@page, :id, :title, :seo_title, :meta_description, :meta_keywords)

    json.slug @page.slug if !@page.index? && !@page.not_found? && !@page.templatized?

    json.fullpath nice_preview_page_path(@page)
    json.contentEntryId @page.content_entry&.id
    json.sectionsContent sections_content(@page, @sections, @section_definitions)
    json.sectionsDropzoneContent sections_dropzone_content(@page)
  end

  json.sectionDefinitions @section_definitions

  json.editableElements @editable_elements

  json.sections do
    json.all      sections_by_id(@sections, @page)
    json.top      @sections[:top]
    json.bottom   @sections[:bottom]
    json.dropzone @sections[:dropzone]
  end

  json.locale   current_content_locale
  json.locales  current_site.locales
end

json.urls do
  json.base             pages_path(current_site)
  json.load             edit_page_content_path(current_site, @page)
  json.save             page_content_path(current_site, @page, format: :json)
  json.editableElements editable_elements_path(current_site, @page)
  json.settings         edit_page_path(current_site, @page)
  json.preview          preview_page_path(@page, mounted_on: true)
  json.thumbnail        root_path + '_image_thumbnail'
  json.assets           content_assets_path(current_site, format: :json)
  json.bulkAssetUpload  bulk_create_content_assets_path(current_site, :json)
  json.resources        search_for_resources_path(current_site, format: :json)
  json.loaderImage      image_url('locomotive/editor_loader.gif')
  json.deadendImage     image_url('locomotive/deadend.png')
end
