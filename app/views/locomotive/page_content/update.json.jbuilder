if current_site.valid? && @page.valid?
  json.success true
  json.previewPath preview_page_path(@page, mounted_on: true) # in case the slug of the page changed
else
  json.success false
  json.errors ({ site: current_site.errors, page: @page.errors })
end
