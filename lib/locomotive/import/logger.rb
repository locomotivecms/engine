module Locomotive
  module Import
    module Logger

      def log(message, domain = '')
        head = "[import_template]"
        head += "[#{domain}]" unless domain.blank?
        ::Locomotive::Logger.info "\t#{head} #{message}"
      end

    end
  end
end