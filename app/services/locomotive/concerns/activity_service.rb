module Locomotive
  module Concerns
    module ActivityService

      # TODO:

      def create_activity(key, options = {})
        site  = respond_to?(:site) ? site : options.delete(:site)

        if options[:actor].blank? && respond_to?(:account)
          options[:actor] = account
        end

        site.activities.create options.merge(key: key)
      end

    end

  end
end
