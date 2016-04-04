module Locomotive
  module Steam

    class AsyncEmailService < EmailService

      def send_email!(options)
        _options = prepare_options_for_async(options)

        SendPonyEmailJob.perform_later(_options)
      end

      protected

      def prepare_options_for_async(options)
        _options = options.deep_stringify_keys

        # convert symbol values to string
        _options['via'] = _options['via'].to_s if _options['via']

        if _options['via_options'] && (value = _options['via_options']['authentication'])
          _options['via_options']['authentication'] = value.to_s
        end

        # if attachments, encode them in base64 to avoid encoding
        # errors when persisting them in Redis.
        (_options['attachments'] || {}).each do |name, content|
          _options['attachments'][name] = Base64.encode64(content)
        end

        _options
      end

    end

  end
end
