json.data do
  json.site do
    json.sectionsContent static_sections_content(current_site, @static_section_types, @section_definitions)
  end

  json.page do
    json.(@page, :id, :title)
    json.sectionsContent sections_content(@page)
  end

  json.sectionDefinitions @section_definitions

  json.editableElements @editable_elements

  json.sections do
    json.all      all_static_sections(@static_section_types)
    json.top      top_static_sections(@static_section_types)
    json.bottom   bottom_static_sections(@static_section_types)
    json.dropzone @static_section_types.include?('_sections_dropzone_')
  end
end

json.urls do
  json.base             pages_path(current_site)
  json.load             edit_page_content_path(current_site, @page)
  json.save             page_content_path(current_site, @page, format: :json)
  json.editableElements editable_elements_path(current_site, @page)
  json.settings         edit_page_path(current_site, @page)
  json.preview          @preview_path
  json.thumbnail        root_path + '_image_thumbnail'
  json.assets           content_assets_path(current_site, format: :json)
  json.bulkAssetUpload  bulk_create_content_assets_path(current_site, :json)
  json.resources        search_for_resources_path(current_site, format: :json)
end
