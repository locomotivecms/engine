require 'spec_helper'

describe Locomotive::Export do

  context '#content_type' do

    before(:each) do
      site = FactoryGirl.build('another site')
      Site.stubs(:find).returns(site)
      project_type = build_project_type(site)
      project_type.contents.build(:title => 'Project #1', :description => 'Lorem ipsum', :active => true)
      project_type.contents.build(:title => 'Project #2', :description => 'More Lorem ipsum', :active => false)

      team_type = build_team_type(site, project_type)
      team_type.contents.build(:name => 'Ben', :projects => project_type.contents, :current_project => project_type.contents.first)
      team_type.contents.build(:name => 'Zach', :current_project => project_type.contents.last)

      @project_data = ::Locomotive::Export.new(site).send(:extract_contents, project_type)
      @team_data = ::Locomotive::Export.new(site).send(:extract_contents, team_type)
    end

    it 'includes the exact number of contents' do
      @project_data.size.should == 2
      @project_data.collect { |n| n.keys.first }.should == ['Project #1', 'Project #2']
    end

    it 'deals with real booleans' do
      @project_data.first.values.first['active'].should be_true
    end

    it 'stores the list of highlighted values in a has_many relationship' do
      @team_data.first.values.first['projects'].size.should == 2
      @team_data.first.values.first['projects'].should == ['Project #1', 'Project #2']
      @team_data.last.values.first['projects'].should be_nil
    end

    it 'stores a highlighted value in a has_one relationship' do
      @team_data.collect { |n| n.values.first['current_project'] }.should == ['Project #1', 'Project #2']
    end

    def build_project_type(site)
      FactoryGirl.build(:content_type, :site => site, :highlighted_field_name => 'custom_field_1').tap do |content_type|
        content_type.content_custom_fields.build :label => 'Title', :_alias => 'title', :kind => 'string'
        content_type.content_custom_fields.build :label => 'My Description', :_alias => 'description', :kind => 'text'
        content_type.content_custom_fields.build :label => 'Active', :kind => 'boolean'
      end
    end

    def build_team_type(site, project_type)
      Object.send(:remove_const, 'TestProject') rescue nil
      klass = Object.const_set('TestProject', Class.new { def self.embedded?; false; end })
      content_type = FactoryGirl.build(:content_type, :site => site, :name => 'team', :highlighted_field_name => 'custom_field_1')
      content_type.content_custom_fields.build :label => 'Name', :_alias => 'name', :kind => 'string'
      content_type.content_custom_fields.build :label => 'Projects', :kind => 'has_many', :_alias => 'projects', :target => 'TestProject'
      content_type.content_custom_fields.build :label => 'Bio', :_alias => 'bio', :kind => 'text'
      content_type.content_custom_fields.build :label => 'Current Project', :kind => 'has_one', :_alias => 'current_project', :target => 'TestProject'
      content_type
    end

  end

  context '#zipfile' do

    before(:all) do
      @site = FactoryGirl.create('another site')

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
      Dir[File.join(self.zip_folder, 'app', 'views', 'pages', '**/*.liquid')].size.should == 11
    end

    it 'includes snippets' do
      self.unzip
      Dir[File.join(self.zip_folder, 'app', 'views', 'snippets', '*.liquid')].size.should == 1
    end

    it 'has yaml files describing the content types as well as their data' do
      self.unzip
      Dir[File.join(self.zip_folder, 'app', 'content_types', '*.yml')].size.should == 4
      Dir[File.join(self.zip_folder, 'data', '*.yml')].size.should == 4
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
      File.join(File.dirname(@zip_file), 'locomotive-test-website-2')
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
      FileUtils.rm_rf(self.zip_folder) if File.exists?(self.zip_folder)
      Site.destroy_all
    end

  end

end