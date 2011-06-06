module Extensions
  module ContentType
    module ItemTemplate

      extend ActiveSupport::Concern

      included do
        field :raw_item_template
        field :serialized_item_template, :type => Binary

        before_validation :serialize_item_template

        validate :item_template_must_be_valid
      end

      module InstanceMethods

        def item_template
          @item_template ||= Marshal.load(read_attribute(:serialized_item_template).to_s) rescue nil
        end

        protected

        def serialize_item_template
          if self.new_record? || self.raw_item_template_changed?
            @item_parsing_errors = []

            begin
              self._parse_and_serialize_item_template
            rescue ::Liquid::SyntaxError => error
              @item_parsing_errors << I18n.t(:liquid_syntax, :error => error.to_s, :scope => [:errors, :messages])
            end
          end
        end

        def _parse_and_serialize_item_template
          item_template = ::Liquid::Template.parse(self.raw_item_template, {})
          self.serialized_item_template = BSON::Binary.new(Marshal.dump(item_template))
        end

        def item_template_must_be_valid
          @item_parsing_errors.try(:each) { |msg| self.errors.add :item_template, msg }
        end

        # def item_template
        #   self.read_attribute(:default_item_template) || self.default_item_template
        # end
        #
        # def default_item_template
        #   '{{ content.highlighted_field_value }}'
        # end

      end

    end
  end
end