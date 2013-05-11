require 'spec_helper'

describe Locomotive::EditableFile do

  before(:each) do
    @site = FactoryGirl.create(:site)
    @home = @site.pages.root.first

    @home.update_attributes raw_template: "{% block body %}{% editable_file 'image' %}Lorem ipsum{% endeditable_file %}{% endblock %}"

    @home = @site.pages.root.first
  end

  it 'has one editable file element' do
    @home.editable_elements.size.should == 1
    @home.editable_elements.first.slug.should == 'image'
  end

  it 'disables the default content flag if the remove_source method is called' do
    @home.editable_elements.first.remove_source = true
    @home.save; @home.reload
    @home.editable_elements.first.default_content?.should be_false
  end

  it 'disables the default content when a new file is uploaded' do
    @home.editable_elements.first.source = FixturedAsset.open('5k.png')
    @home.save
    @home.editable_elements.first.default_content?.should be_false
  end

  it 'does not have 2 image fields' do
    editable_file = @home.editable_elements.first
    fields = editable_file.class.fields.keys
    (fields.include?('source') && fields.include?(:source)).should be_false
  end

  describe 'with an attached file' do

    before(:each) do
      @editable_file = @home.editable_elements.first
      @editable_file.source = FixturedAsset.open('5k.png')
      # @editable_file.save
      # Rails.logger.debug "------------- START --------"
      # puts "changed"
      # puts @editable_file.changed.inspect
      # puts "changes"
      # puts @editable_file.changes.inspect
      # puts @home.changes.inspect
      @home.save
      @home.reload
      # puts @editable_file.inspect
      # puts @home.errors.inspect
      # Rails.logger.debug "------------- DONE --------"
      # @home = Locomotive::Page.find(@home._id)
    end

    it 'has a valid source' do
      @editable_file.source?.should be_true
      # puts @editable_file.source.inspect
    end

    it 'returns the right path even if the page has been retrieved with the minimum_attributes scope' do
      # @home = @site.pages.minimal_attributes(%w(editable_elements)).root.first
      @home = @site.pages.root.first
      # puts @home.inspect
      # puts @home.editable_elements.inspect
      @home.editable_elements.first.source?.should be_true
    end

  end

  describe '"sticky" files' do

    before(:each) do
      @home.update_attributes raw_template: "{% block body %}{% editable_file 'image', fixed: true %}/foo.png{% endeditable_file %}{% endblock %}"

      @sub_page_1 = FactoryGirl.create(:page, slug: 'sub_page_1', parent: @home, raw_template: "{% extends 'index' %}")
      @sub_page_2 = FactoryGirl.create(:page, slug: 'sub_page_2', parent: @home, raw_template: "{% extends 'index' %}")

      @sub_page_1_el = @sub_page_1.editable_elements.first
      @sub_page_2_el = @sub_page_2.editable_elements.first
    end

    it 'exists in sub pages' do
      @sub_page_1.editable_elements.size.should == 1
      @sub_page_2.editable_elements.size.should == 1
    end

    it 'is marked as fixed' do
      @sub_page_1_el.fixed?.should be_true
      @sub_page_2_el.fixed?.should be_true
    end

    it 'enables the default content when it just got created' do
      @sub_page_1_el.source?.should be_false
      @sub_page_1_el.default_source_url.should == '/foo.png'
      @sub_page_1_el.default_content?.should be_true
    end

    it 'gets also updated when updating the very first element' do
      @home.editable_elements.first.source = FixturedAsset.open('5k.png')
      @home.save; @sub_page_1.reload; @sub_page_2.reload
      @sub_page_1.editable_elements.first.default_source_url.should be_true
      @sub_page_1.editable_elements.first.default_source_url.should =~ /files\/5k.png$/
      @sub_page_2.editable_elements.first.default_source_url.should be_true
      @sub_page_2.editable_elements.first.default_source_url.should =~ /files\/5k.png$/
    end

  end

end
