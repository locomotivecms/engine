module Locomotive
  module Dragonfly

    def self.resize_url(source, resize_string)
      file = nil

      if source.is_a?(String) || source.is_a?(Hash) # simple string or theme asset
        source = source['url'] if source.is_a?(Hash)

        source.strip!

        if source =~ /^http/
          file = self.app.fetch_url(source)
        else
          file = self.app.fetch_file(File.join('public', source))
        end

      elsif source.respond_to?(:url) # carrierwave uploader
        if source.file.respond_to?(:url)
          file = self.app.fetch_url(source.url) # amazon s3, cloud files, ...etc
        else
          file = self.app.fetch_file(source.path)
        end

      else
        Locomotive.log :error, "Unable to resize on the fly: #{source.inspect}"
        return
      end

      file.process(:thumb, resize_string).url
    end

    def self.app
      ::Dragonfly[:images]
    end

  end
end