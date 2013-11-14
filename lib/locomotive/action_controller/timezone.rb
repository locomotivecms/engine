module Locomotive
  module ActionController
    module Timezone

      protected

      def set_timezone(&block)
        Time.use_zone(current_site.try(:timezone) || 'UTC', &block)
      end

    end
  end
end