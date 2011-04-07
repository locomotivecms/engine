class EditableFileUploader < ::CarrierWave::Uploader::Base

  def store_dir
    self.build_store_dir('sites', model.page.site_id, 'pages', model.page.id, 'files')
  end

  # def cache_dir
  #   "#{Rails.root}/tmp/uploads"
  # end

end