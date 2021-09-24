module Locomotive
  module Concerns
    module ContentType
      module Import

        extend ActiveSupport::Concern

        included do
          field :import_enabled, type: Boolean, default: false
          field :raw_import_state, type: Hash, default: nil
        end

        def import_state
          @import_state ||= ImportState.new(raw_import_state)
        end

        def can_import?          
          import_enabled? && import_state.can_start?
        end

        def importing?
          import_state.running?
        end

        def import_status
          import_state.status
        end

        def start_import(total:)
          change_import_state({
            'status' => 'in_progress', 'total_rows' => total
          }, true)
        end

        def finish_import
          change_import_state({ 'status' => 'done' })
        end

        def cancel_import(error_message)
          change_import_state({ 'status' => 'canceled', 'error' => error_message })
        end

        def on_imported_row(index, row_status)
          change_import_state({
            row_status.to_s => import_state.rows_count(row_status.to_s) + 1,
            'failed_ids' => import_state.failed_rows_ids + (row_status.to_s == 'failed' ? [index] : []),
          })
        end

        def change_import_state(attributes, clear_state = false)
          new_attributes = ((clear_state ? nil : raw_import_state) || {}).merge(attributes)
          update(raw_import_state: new_attributes.merge('updated_at' => Time.zone.now)).tap do
            @import_state = nil # reset the state object
          end
        end

        class ImportState

          def initialize(raw_state)
            @raw_state = raw_state || { 'status' => 'ready' }
          end

          def can_start?
            !running?
          end

          def running?
            status == :in_progress
          end

          def status
            @raw_state['status'].to_sym
          end

          def total_rows
            @raw_state['total_rows']
          end
          
          def processed_rows_count
            created_rows_count + updated_rows_count + failed_rows_count
          end

          def rows_count(topic)
            @raw_state[topic] || 0
          end

          def created_rows_count
            rows_count('created')
          end

          def updated_rows_count
            rows_count('updated')
          end

          def failed_rows_count
            rows_count('failed')
          end

          def failed_rows_ids
            @raw_state['failed_ids'] || []
          end
        end        
      end
    end
  end

  class ContentEntryImport
    include ActiveModel::Model
    
    attr_accessor :file, :col_sep, :quote_char
    
    validates_each :file do |record, attr, value|
      record.errors.add attr, :blank if value.blank?
    end

    def options
      { col_sep: col_sep || ',', quote_char: quote_char || "\"" }
    end

    def file?
      file.present?
    end
  end
end