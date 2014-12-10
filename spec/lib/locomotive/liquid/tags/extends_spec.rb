require 'spec_helper'

describe Locomotive::Liquid::Tags::Extends do

  before(:each) do
    @home = FactoryGirl.build(:page, raw_template: 'Hello world')
    @home.send :serialize_template
    @home.instance_variable_set(:@template, nil)

    @site = FactoryGirl.build(:site)
    @site.stubs(:pages).returns([@home])
  end

  it 'works' do
    page = FactoryGirl.build(:page, slug: 'sub_page_1', parent: @home)
    parse('parent', page).render.should == 'Hello world'
  end

  it 'looks for the index with the right locale' do
    ::Mongoid::Fields::I18n.with_locale 'fr' do
      @home.raw_template = 'Bonjour le monde'
      @home.send :serialize_template
    end

    @site.pages.expects(:where).with('fullpath.fr' => 'index').returns([@home])

    ::Mongoid::Fields::I18n.with_locale 'fr' do
      page = FactoryGirl.build(:page, slug: 'sub_page_1', parent: @home)
      parse('index', page).render.should == 'Bonjour le monde'
    end
  end

  context '#errors' do

    it 'raises an error if the source page does not exist' do
      lambda {
        @site.pages.expects(:where).with('fullpath.en' => 'foo').returns([])
        parse('foo')
      }.should raise_error(Locomotive::Liquid::PageNotFound, "Page with fullpath 'foo' was not found")
    end

    it 'raises an error if the source page is not translated' do
      lambda {
        ::Mongoid::Fields::I18n.with_locale 'fr' do
          page = FactoryGirl.build(:page, slug: 'sub_page_1', parent: @home)
          parse('parent', page)
        end
      }.should raise_error(Locomotive::Liquid::PageNotTranslated, "Page with fullpath 'parent' was not translated")
    end

  end

  def parse(source = 'index', page = nil)
    page ||= @home
    Liquid::Template.parse("{% extends #{source} %}", { site: @site, page: page })
  end

end
