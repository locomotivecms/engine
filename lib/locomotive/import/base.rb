module Locomotive
  module Import
    class Base

      include Logger

      attr_reader :context, :options

      def initialize(context, options)
        @context = context
        @options = options
        self.log "*** starting to process ***"
      end

      def self.process(context, options)
        self.new(context, options).process
      end

      def process
        raise 'this method has to be overidden'
      end

      def log(message)
        super(message, self.class.name.demodulize.underscore)
      end

      protected

      def site
        @context[:site]
      end

      def database
        @context[:database]
      end

      def theme_path
        @context[:theme_path]
      end

      def open_sample_asset(url)
        File.open(File.join(self.theme_path, 'public', url))
      end
    end
  end
end