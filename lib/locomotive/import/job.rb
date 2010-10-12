require 'zip/zipfilesystem'

module Locomotive
  module Import
    class Job

      def initialize(theme_file, site = nil, enabled = {})
        raise "Theme zipfile not found" unless File.exists?(theme_file)

        @theme_file = theme_file
        @site = site
        @enabled = enabled
      end

      def before(worker)
        @worker = worker
      end

      def perform
        puts "theme_file = #{@theme_file} / #{@site.present?} / #{@enabled.inspect}"

        self.unzip!

        raise "No database.yml found in the theme zipfile" if @database.nil?

        context = {
          :database => @database,
          :site => @site,
          :theme_path => @theme_path,
          :error => nil,
          :worker => @worker
        }

        %w(site content_types assets asset_collections snippets pages).each do |step|
          if @enabled[step] != false
            "Locomotive::Import::#{step.camelize}".constantize.process(context)
            @worker.update_attributes :step => step if @worker
          else
            puts "skipping #{step}"
          end
        end
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
              @theme_path = File.join(destination_path, entry.name.gsub('database.yml', ''))

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