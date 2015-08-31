module Locomotive
  module Dragonfly

    def self.resize_url(source, resize_string)
      if file = self.fetch_file(source)
        file.thumb(resize_string).url
      else
        Locomotive.log :error, "Unable to resize on the fly: #{source.inspect}"
        return
      end
    end

    def self.thumbnail_pdf(source, resize_string)
      if file = self.fetch_file(source)
        file.thumb(resize_string, format: 'png', frame: 0).encode('png').url
      else
        Locomotive.log :error, "Unable to convert the pdf: #{source.inspect}"
        return
      end
    end

    def self.fetch_file(source)
      file = nil

      if source.is_a?(String) || source.is_a?(Hash) # simple string or drop
        source = source['url'] if source.is_a?(Hash)

        clean_source!(source)

        if source =~ /^http/
          file = self.app.fetch_url(source)
        else
          file = self.app.fetch_file(File.join('public', source))
        end

      elsif source.respond_to?(:url) # carrierwave uploader
        if source.path.first == '/'
          file = self.app.fetch_file(source.path)
        else
          file = self.app.fetch_url(source.url)
        end
      end

      file
    end

    def self.app
      ::Dragonfly.app(:engine)
    end

    protected

    def self.clean_source!(source)
      # remove the leading / trailing whitespaces
      source.strip!

      # remove the query part (usually, timestamp) if local file
      source.sub!(/(\?.*)$/, '') unless source =~ /^http/
    end

  end
end
