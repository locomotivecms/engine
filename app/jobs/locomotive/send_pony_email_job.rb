module Locomotive

  class SendPonyEmailJob < ActiveJob::Base

    queue_as :default

    def perform(options)
      _options = prepare_options(options)

      Pony.mail(_options)
    end

    protected

    def prepare_options(options)
      _options = options.deep_symbolize_keys

      _options[:via] = _options[:via].to_sym if _options[:via]
      _options[:via_options] ||= {}

      _options[:via_options][:authentication] = _options.dig(:via_options, :authentication).presence&.to_sym
      _options[:via_options][:user_name]      = _options.dig(:via_options, :user_name).presence
      _options[:via_options][:password]       = _options.dig(:via_options, :password).presence

      # if attachments, decode them because they were enccoding in base64
      if attachments = _options.delete(:attachments)
        _options[:attachments] = {}
        attachments.each do |name, content|
          _options[:attachments][name.to_s] = Base64.decode64(content)
        end
      end

      _options
    end

  end

end
