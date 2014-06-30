module Locomotive
  module Liquid
    module Tags
      module Editable
        class File < Base

          protected

          def default_element_attributes
            if @nodelist.first.is_a?(String)
              super.merge(default_source_url: @nodelist.first.try(:to_s))
            else
              super
            end
          end

          def render_element(context, element)
            default_timestamp = context.registers[:page].updated_at.to_i

            url, timestamp = (if element.source?
              [element.source.url, default_timestamp]
            else
              if element.default_source_url.present?
                [element.default_source_url, default_timestamp]
              else
                [render_default_content(context), nil]
              end
            end)

            context.registers[:asset_host].compute(url, timestamp)
          end

          def document_type
            EditableFile
          end

        end

        ::Liquid::Template.register_tag('editable_file', File)
      end
    end
  end
end
