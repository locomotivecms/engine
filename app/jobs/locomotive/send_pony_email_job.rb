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

      if _options[:via_options] && (value = _options[:via_options][:authentication])
        _options[:via_options][:authentication] = value.to_sym
      end

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
