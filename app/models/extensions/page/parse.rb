module Models
  module Extensions
    module Page
      module Parse

        extend ActiveSupport::Concern

        included do
          field :serialized_template, :type => Binary

          before_validation :serialize_template
        end

        module InstanceMethods

          def template
            @template ||= Marshal.load(read_attribute(:serialized_template).to_s) rescue nil
          end

          protected

          def serialize_template
            if self.new_record? || self.raw_template_changed?
              begin
                @template = ::Liquid::Template.parse(self.raw_template, { :site => self.site })
                @template.root.context.clear

                self.serialized_template = BSON::Binary.new(Marshal.dump(@template))

              rescue ::Liquid::SyntaxError => error
                self.errors.add :template, :liquid_syntax
              rescue ::Locomotive::Liquid::PageNotFound => error
                self.errors.add :template, :liquid_extend
              end
            end
          end

        end

      end
    end
  end
end