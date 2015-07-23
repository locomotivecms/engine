module Locomotive
  module Concerns
    module ActivityService

      def create_activity(key, options = {})
        site = respond_to?(:site) ? self.site : options.delete(:site)

        if options[:actor].blank? && respond_to?(:account)
          options[:actor] = self.account
        end

        site.activities.create! options.merge(key: key)
      end

    end

  end
end
