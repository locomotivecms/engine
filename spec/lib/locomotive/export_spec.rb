require 'spec_helper'

describe Locomotive::Export do

  context 'when successful' do

    before(:all) do
      @site = Factory('another site')

      # first import a brand new site
      self.import_it

      # then export it of course
      @zip_file = self.export_it
    end

    it 'generates a zipfile' do
      @zip_file.should_not be_nil
      File.exists?(@zip_file).should be_true
    end

    it 'has the exact number of pages from the original site' do
      self.unzip
      Dir[File.join(self.zip_folder, 'app', 'views', 'pages', '**/*.liquid')].size.should == 10
    end

    def import_it
      job = Locomotive::Import::Job.new(FixturedTheme.duplicate_and_open('default.zip'), @site, { :samples => true, :reset => true })
      job.perform
      job.success nil
    end

    def export_it
      ::Locomotive::Export.run!(@site, @site.name.parameterize)
    end

    def zip_folder
      File.join(File.dirname(@zip_file), 'acme-website')
    end

    def unzip
      return if @zip_file || File.exists?(self.zip_folder)

      Zip::ZipFile.open(@zip_file) do |zipfile|
        destination_path = File.dirname(@zip_file)
        zipfile.each do |entry|
          FileUtils.mkdir_p(File.dirname(File.join(destination_path, entry.name)))
          zipfile.extract(entry, File.join(destination_path, entry.name))
        end
      end
    end

    after(:all) do
      Site.destroy_all
    end

  end

end