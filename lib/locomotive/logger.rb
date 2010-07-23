module Locomotive
  module Logger

    def self.method_missing(meth, args, &block)
      if Locomotive.config.enable_logs == true
        Rails.logger.send(meth, args)
      end
    end

  end
end
