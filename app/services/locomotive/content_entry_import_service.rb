require 'csv'

# TODO:
# x basic import: CSV -> entries
# x transform all the types of attributes
# x options col_sep + quote_char
# x detect new or existing rows (don't throw an exception if something goes wrong)
# - create a collection to store the progress of an import? / store it in the site itself? ++++ => content type of course!!!
# - async method (can't run an import if already in progress)
# - cancel a job
# - create the controller to trigger a new import
#   - store the CSV file as a content asset
#   - add an async job
#   - try to track the job somehow
# - page to display the status (or current state) of the import
#   - actions: cancel the job 
# - new attribute of a content type: importable / import_enabled (boolean)
#   - steam + wagon?

module Locomotive
  class ContentEntryImportService < Struct.new(:content_type, :account, :locale)

    include Locomotive::Concerns::ActivityService

    def async_import(file, csv_options = nil)
      raise 'TODO'
    end

    def import!(csv_asset_id, csv_options = nil)
      content_type.set_import_status([:in_progress, {}])
      import(csv_asset_id, csv_options).tap do |state|
        content_type.set_import_status(state)
      end
    end

    def import(csv_asset_id, csv_options = nil)
      csv = load_csv(csv_asset_id, csv_options)
      return [:fail, { error: "Can't read the CSV" }] unless csv
      [:ok, import_rows(csv)]
    end

    private

    def import_rows(csv)
      report = { created: 0, updated: 0, failed: [] }
      csv.each_with_index do |row, index|
        entry = content_type.entries.where(_slug: row['_slug']).first || content_type.entries.build
        is_new_entry = !entry.persisted?
        entry.attributes = attributes_from_row(row)

        if entry.save
          report[is_new_entry ? :created : :updated] += 1
        else
          report[:failed] << index
        end
      end
      report
    end

    def attributes_from_row(row)
      attributes = {}
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
      return if asset.nil?
      CSV.parse(asset.source.read, csv_options)
    end
    
    def transform_attribute(field, value)
      # puts "TODO transform_attribute #{field.name}(#{field.type}), value = #{value}"
      case field.type
      when 'string'
        field.name =~ /_asset_url$/ ? 
        [field.name, content_assets.where(filename: value).first&.source&.url] :
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