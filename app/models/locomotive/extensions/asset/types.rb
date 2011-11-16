module Locomotive
  module Extensions
    module Asset
      module Types

        extend ActiveSupport::Concern

        included do
          %w{media image stylesheet javascript font pdf}.each do |type|
            scope :"only_#{type}", where(:content_type => type)

            define_method("#{type}?") do
              self.content_type.to_s == type
            end
          end
        end

        module ClassMethods

          def by_content_type(content_type)
            return self.all if content_type.blank?

            self.all.where(:content_type => content_type.to_s)
          end

        end

      end
    end
  end
end