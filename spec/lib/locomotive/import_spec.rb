require 'spec_helper'

describe Locomotive::Import::Job do

  context 'when successful' do

    before(:all) do
      @site = FactoryGirl.create(:site)

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

    it 'replaces the target and the reverse_lookup values by the correct ones in a has_many relationship' do
      content_type = @site.content_types.where(:slug => 'clients').first
      field = content_type.content_custom_fields.last
      field.target.should match /^ContentContentType/
      field.reverse_lookup.should == 'custom_field_8'
    end

    it 'correctly imports content type names' do
      content_type = @site.content_types.where(:slug => 'projects').first
      content_type.name.should == 'My projects'
    end

    it 'converts correctly the order_by option for content types' do
      content_type = @site.content_types.where(:slug => 'messages').first
      content_type.order_by.should == 'created_at'
    end

    it 'adds samples coming with content types' do
      content_type = @site.content_types.where(:slug => 'projects').first
      content_type.contents.size.should == 5

      content = content_type.contents.first
      content._permalink.should == 'locomotivecms'
      content.seo_title.should == 'My open source CMS'
      content.meta_description.should == 'bla bla bla'
      content.meta_keywords.should == 'cms ruby engine mongodb'
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

    it 'sets the editable text for a page from the site config file' do
      page = @site.pages.where(:title => 'Contact').first
      page.find_editable_element('content', 'address').content.should == '<p>Our office address: 215 Vine Street, Scranton, PA 18503</p>'
    end

    it 'sets the editable file for a page from the site config file' do
      page = @site.pages.where(:title => 'Contact').first
      page.find_editable_element('content', 'office').source_filename.should == 'office.jpg'
    end

    it 'sets the empty editable file for a page from the site config file' do
      page = @site.pages.where(:title => 'Contact').first
      page.find_editable_element('content', 'office2').source_filename.should be_nil
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

  context 'with an existing site' do
    before(:all) do
      @site = FactoryGirl.create('existing site')

      job = Locomotive::Import::Job.new(FixturedTheme.duplicate_and_open('default.zip'), @site, { :samples => true, :reset => false })
      job.perform

      job.success nil
    end

    context 'updates to content_type attributes' do
      before(:all) do
        @projects = content_type = @site.content_types.where(:slug => 'projects').first
      end

      it 'includes new name' do
        @projects.name.should == 'My projects'
      end

      it 'includes new description' do
        @projects.description.should == 'My portfolio'
      end

      it 'includes new order by' do
        @projects.order_by.should == '_position_in_list'
      end
    end
  end

end
