module Locomotive
  module Logger

    def self.method_missing(meth, message, &block)
      if Locomotive.config.enable_logs == true
        Rails.logger.send(meth, "[LocomotiveCMS] #{message}")
      end
    end

  end
end
