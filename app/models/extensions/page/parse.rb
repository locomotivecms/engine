module Models
  module Extensions
    module Page
      module Parse

        extend ActiveSupport::Concern

        included do
          field :serialized_template, :type => Binary

          before_validation :serialize_template

          validate :template_must_be_valid
        end

        module InstanceMethods

          def template
            @template ||= Marshal.load(read_attribute(:serialized_template).to_s) rescue nil
          end

          protected

          def parse
            @template = ::Liquid::Template.parse(self.raw_template, { :site => self.site, :page => self })
            @template.root.context.clear

            # TODO: walk thru the document tree to get parents as well as used snippets
          end

          def serialize_template
            if self.new_record? || self.raw_template_changed?
              @parsing_errors = []

              begin
                self.parse

                self.serialized_template = BSON::Binary.new(Marshal.dump(@template))

                # TODO: let other pages inheriting from that one and modify them in consequences

                # TODO: build array of parent pages

              rescue ::Liquid::SyntaxError => error
                @parsing_errors << :liquid_syntax
              rescue ::Locomotive::Liquid::PageNotFound => error
                @parsing_errors << :liquid_extend
              end
            end
          end

          def template_must_be_valid
            @parsing_errors.try(:each) { |msg| self.errors.add :template, msg }
          end

        end

      end
    end
  end
end