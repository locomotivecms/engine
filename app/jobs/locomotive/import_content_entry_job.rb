module Locomotive
  class ImportContentEntryJob < ActiveJob::Base

    queue_as :default

    def perform(content_type_id, csv_asset_id, csv_options)
      content_type = Locomotive::ContentType.find(content_type_id)
      service = Locomotive::ContentEntryImportService.new(content_type)
      service.import(csv_asset_id, csv_options)
    end
  end
end