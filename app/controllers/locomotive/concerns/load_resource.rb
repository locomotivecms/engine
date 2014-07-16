module Locomotive
  module Concerns
    module LoadResource
      # extend ActiveSupport::Concern

      class << self
        def singular_name
          plural_name.singularize
        end

        def plural_name
          self.name.split('::').last.gsub('Controller','').underscore
        end
      end

      # included do
      #   before_filter :load_resource,  only: [:show, :update, :destroy]
      #   before_filter :load_resources, only: [:index]
      # end

      class_eval <<-METHODS, __FILE__, __LINE__
        def load_#{singular_name}
          @#{singular_name} = current_site.#{plural_name}.find params[:id]
        end

        def load_#{plural_name}
          @#{plural_name} = current_site.#{plural_name}
        end
      METHODS

    end
  end
end
