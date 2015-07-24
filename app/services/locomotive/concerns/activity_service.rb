module Locomotive
  module Concerns
    module ActivityService

      def track_activity(key, options = {})
        return if @activity_disabled

        site = respond_to?(:site) ? self.site : options.delete(:site)

        if options[:actor].blank? && respond_to?(:account)
          options[:actor] = self.account
        end

        site.activities.create! options.merge(key: key)
      end

      def without_tracking_activity(&block)
        @activity_disabled = true
        yield.tap do
          @activity_disabled = false
        end
      end

    end

  end
end
