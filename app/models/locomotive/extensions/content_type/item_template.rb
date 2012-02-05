module Locomotive
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
          @item_parsing_errors.try(:each) do |msg|
            %w(item_template raw_item_template).each { |field| self.errors.add field.to_sym, msg }
          end
        end

      end
    end
  end
end