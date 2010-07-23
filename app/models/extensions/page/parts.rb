module Models
  module Extensions
    module Page
      module Parts

        extend ActiveSupport::Concern

        included do

          before_create { |p| p.parts << PagePart.build_body_part if p.parts.empty? }

        end

        module InstanceMethods

          def parts_attributes=(attributes)
            self.update_parts(attributes.values.map { |attrs| PagePart.new(attrs) })
          end

          def joined_parts
            self.parts.enabled.map(&:template).join('')
          end

          protected

          def update_parts(parts)
            performed = []

            # add / update
            parts.each do |part|
              if (existing = self.parts.detect { |p| p.id == part.id || p.slug == part.slug })
                existing.attributes = part.attributes.delete_if { |k, v| %w{_id slug}.include?(k) }
              else
                self.parts << (existing = part)
              end
              performed << existing unless existing.disabled?
            end

            # disable missing parts
            (self.parts.map(&:slug) - performed.map(&:slug)).each do |slug|
              self.parts.detect { |p| p.slug == slug }.disabled = true
            end
          end

          def update_parts!(new_parts)
            self.update_parts(new_parts)
            self.save
          end

        end
      end
    end
  end
end
