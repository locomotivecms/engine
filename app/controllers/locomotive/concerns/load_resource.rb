module Locomotive
  module Concerns
    module LoadResource
      extend ActiveSupport::Concern

      class << self
        def singular_name
          plural_name.singularize
        end

        def plural_name
          self.name.split('::').last.gsub('Controller','').underscore
        end
      end

      def self.included(base)
        base.class_eval <<-EOV, __FILE__, __LINE__
          before_filter :load_#{singular_name}, only: [:show, :destroy]
        EOV
        base.class_eval <<-EOV, __FILE__, __LINE__
          before_filter :load_#{plural_name},   only: [:index]
        EOV
      end

      class_eval <<-METHODS, __FILE__, __LINE__
        def load_#{singular_name}
          @#{singular_name} = current_site.#{plural_name}.find params[:id]
        end

        def load_#{plural_name}
          @#{plural_name} = current_site.#{plural_name}.all
        end
      METHODS

    end
  end
end
