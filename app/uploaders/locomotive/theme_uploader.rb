# encoding: utf-8

module Locomotive
  class ThemeUploader < ::CarrierWave::Uploader::Base

    def store_dir
      if Locomotive.config.delayed_job
        self.build_store_dir('sites', model.id.to_s, 'tmp', 'themes')
      else
        "#{Rails.root}/tmp/themes"
      end
    end

    def extension_white_list
      %w(zip)
    end

  end
end