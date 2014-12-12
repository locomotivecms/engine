module Locomotive
  module Concerns
    module Asset
      module Types

        extend ActiveSupport::Concern

        included do
          scope :by_content_type,   ->(content_type)  { content_type.blank? ? all : where(content_type: content_type.to_s) }
          scope :by_content_types,  ->(content_types) { content_types.blank? ? all : where(:content_type.in => [*content_types]) }

          all_types.each do |type|
            scope :"only_#{type}", -> { where(content_type: type) }

            define_method("#{type}?") do
              self.content_type.to_s == type
            end
          end
        end

        module ClassMethods

          def all_types
            %w{image pdf media stylesheet javascript font}
          end

          def types_for_content_editing
            all_types - %w(stylesheet javascript font)
          end

        end

      end
    end
  end
end
