require 'csv'

module Locomotive
  class ContentEntryImportService < Struct.new(:content_type)

    class WrongImportFileException < StandardError; end

    def async_import(file, csv_options = nil)
      csv_asset = content_assets.create(source: file)
      Locomotive::ImportContentEntryJob.perform_later(
        content_type.id.to_s,
        csv_asset.id.to_s,
        csv_options
      )
    end

    def import(csv_asset_id, csv_options = nil)
      begin
        csv = load_csv(csv_asset_id, csv_options)
      rescue WrongImportFileException => e
        content_type.cancel_import(e.message)
        return false
      end 

      content_type.start_import(total: csv.count)
      import_rows(csv)
      content_type.finish_import

      content_assets.destroy_all(id: csv_asset_id)
    end

    def cancel(reason)
      content_type.cancel_import(reason)
    end

    private

    def import_rows(csv)
      csv.each_with_index do |row, index|
        entry = content_type.entries.where(_slug: row['_slug']).first || content_type.entries.build
        import_row(row, index, entry)
      end
    end

    def import_row(row, index, entry)
      is_new_entry = !entry.persisted?
      entry.attributes = attributes_from_row(row)
      
      if entry.save
        content_type.on_imported_row(index, is_new_entry ? :created : :updated) 
      else
        content_type.on_imported_row(index, :failed)
      end
    rescue Exception => e
      Rails.logger.error e.message # don't hide the exception
      Rails.logger.error e.backtrace.join("\n")
      content_type.on_imported_row(index, :failed)
    end

    def attributes_from_row(row)
      attributes = { _slug: row['_slug'] }
      content_type.entries_custom_fields.each do |field|
        next if row[field.name].blank?
        name, value = transform_attribute(field, row[field.name])
        attributes[name] = value
      end
      attributes
    end

    def load_csv(csv_asset_id, csv_options = nil)
      csv_options = { headers: true, col_sep: ';', quote_char: "\"" }.merge(csv_options || {})
      asset = content_assets.where(id: csv_asset_id).first
      raise 'The CSV file doesn\'t exist anymore' unless asset
      CSV.parse(asset.source.read, csv_options)
    rescue Exception => e
      raise WrongImportFileException.new e.message
    end
    
    def transform_attribute(field, value)
      case field.type
      when 'string'
        field.name =~ /_asset_url$/ ? 
        [field.name, content_assets.where(source_filename: value).order_by(:created_at.desc).first&.source&.url] :
        [field.name, value]
      when 'belongs_to'
        [field.name, fetch_entry_ids(field.class_name, value).first]
      when 'many_to_many'
        ["#{field.name.singularize}_ids", fetch_entry_ids(field.class_name, value.split(','))]
      else
        [field.name, value]
      end
    end

    def content_assets
      content_type.site.content_assets
    end

    def fetch_entry_ids(class_name, ids_or_slugs)
      return [] if ids_or_slugs.blank?

      ids_or_slugs  = [*ids_or_slugs]
      klass         = class_name.constantize

      klass.by_ids_or_slugs(ids_or_slugs).pluck(:_id)
    end
  end
end