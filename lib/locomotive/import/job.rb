require 'zip/zipfilesystem'

module Locomotive
  module Import
    class Job

      def initialize(theme_file, site = nil, options = {})
        raise "Theme zipfile not found" unless File.exists?(theme_file)

        @theme_file = theme_file
        @site = site
        @options = Hash.new(true).merge(options)
      end

      def perform
        self.unzip!

        raise "No database.yml found in the theme zipfile" if @database.nil?

        context = {
          :database => @database,
          :site => @site,
          :theme_path => @theme_path
        }
        
        Locomotive::Import::Site.process(context)

        Locomotive::Import::ContentTypes.process(context)

        # Locomotive::Import::Assets.process(context)

        Locomotive::Import::Snippets.process(context)

        Locomotive::Import::Pages.process(context)
      end

      protected

      def unzip!
        Zip::ZipFile.open(@theme_file) do |zipfile|
          destination_path = File.join(Rails.root, 'tmp', 'themes', @site.id.to_s)
          
          FileUtils.rm_r destination_path, :force => true          

          zipfile.each do |entry|
            next if entry.name =~ /__MACOSX/

            if entry.name =~ /database.yml$/

              @database = YAML.load(zipfile.read(entry.name))
              @theme_path= File.join(destination_path, entry.name.gsub('database.yml', ''))

              next
            end

            FileUtils.mkdir_p(File.dirname(File.join(destination_path, entry.name)))

            zipfile.extract(entry, File.join(destination_path, entry.name))
          end
        end

      end

    end
  end
end