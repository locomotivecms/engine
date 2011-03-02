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
      @site.content_types.count.should == 2
      content_type = @site.content_types.where(:slug => 'projects').first
      content_type.content_custom_fields.size.should == 6
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
    end

    it 'inserts theme assets' do
      @site.theme_assets.count.should == 10
    end

    it 'hides some theme assets' do
      asset = @site.theme_assets.where(:local_path => 'stylesheets/style.css').first
      asset.hidden.should == false

      asset = @site.theme_assets.where(:local_path => 'stylesheets/ie7.css').first
      asset.hidden.should == true
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

    after(:all) do
      Site.destroy_all
    end

  end

end