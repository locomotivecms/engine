require 'spec_helper'

describe Locomotive::Import::Job do

  context 'when successful' do

    before(:all) do
      @site = Factory(:site)

      job = Locomotive::Import::Job.new(FixturedTheme.duplicate_and_open('default.zip'), @site, { :samples => true, :reset => true })
      job.perform

      job.success nil
    end

    it 'updates the site information' do
      @site.name.should_not == "HTML5 portfolio"
      @site.meta_keywords.should == "html5 portfolio theme locomotive cms"
      @site.meta_description.should == "portfolio powered by html5"
    end

    it 'adds content types' do
      @site.content_types.count.should == 4
      content_type = @site.content_types.where(:slug => 'projects').first
      content_type.content_custom_fields.size.should == 9
    end

    it 'converts correctly the order_by option for content types' do
      content_type = @site.content_types.where(:slug => 'messages').first
      content_type.order_by.should == 'created_at'
    end

    it 'adds samples coming with content types' do
      content_type = @site.content_types.where(:slug => 'projects').first
      content_type.contents.size.should == 5

      content = content_type.contents.first
      content.name.should == 'Locomotive App'
      content.thumbnail.url.should_not be_nil
      content.featured.should == true
      content.client.name.should == 'My client #1'
      content.team.first.name.should == 'Michael Scott'
    end

    it 'inserts theme assets' do
      @site.theme_assets.count.should == 10
    end

    it 'inserts all the pages' do
      @site.pages.count.should == 11
    end

    it 'inserts the index and 404 pages' do
      @site.pages.root.first.should_not be_nil
      @site.pages.not_found.first.should_not be_nil
    end

    it 'inserts templatized page' do
      page = @site.pages.where(:templatized => true).first
      page.should_not be_nil
      page.fullpath.should == 'portfolio/content_type_template'
    end

    it 'inserts redirection page' do
      page = @site.pages.where(:redirect => true).first
      page.should_not be_nil
      page.redirect_url.should == 'http://blog.locomotivecms.com'
    end

    it 'inserts snippets' do
      @site.snippets.count.should == 1
    end

    after(:all) do
      Site.destroy_all
    end

  end
  
  context 'with locomotive editor default theme' do
    def import(options)
      job = Locomotive::Import::Job.new(FixturedTheme.duplicate_and_open('default-from-editor.zip'), @site, options)
      job.perform

      job.success nil
    end
    
    before(:all) do
      @site = Factory(:site)
    end
    
    it 'should just import without errors' do
      import({ :samples => false, :reset => false })
    end
    
    it 'should grab samples without errors' do
      import({ :samples => true, :reset => false })
    end
    
    it 'should reset site without error' do
      import({ :samples => false, :reset => true })
    end

    it 'should grab samples and reset site without errors' do
      import({ :samples => true, :reset => true })
    end
    
    after(:all) do
      Site.destroy_all
    end
  end
  
  context 'with layouts-folder theme' do
    before(:all) do
      @site = Factory(:site)
    end
    
    it 'should run without errors' do
      job = Locomotive::Import::Job.new(FixturedTheme.duplicate_and_open('layouts-folder.zip'), @site, { :samples => false, :reset => false })
      job.perform

      job.success nil
    end

    after(:all) do
      Site.destroy_all
    end
  end

end