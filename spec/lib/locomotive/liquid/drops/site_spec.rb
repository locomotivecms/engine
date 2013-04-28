require 'spec_helper'

describe Locomotive::Liquid::Drops::Site do

  before(:each) do
    @site   = FactoryGirl.build(:site)
    page_1  = FactoryGirl.build(:page, site: @site)
    page_2  = FactoryGirl.build(:page, site: @site, title: 'About us', slug: 'about_us')
    @site.stubs(:pages).returns([page_1, page_2])
  end

  context '#pages' do

    it 'has access to all the pages' do
      render_template('{{ site.pages.size }}').should == '2'
    end

    it 'loops thru the pages' do
      render_template('{% for page in site.pages %}{{ page.title }} {% endfor %}').should == 'Home page About us '
    end

  end

  def render_template(template = '', assigns = {})
    assigns = {
      'site' => @site
    }.merge(assigns)

    Liquid::Template.parse(template).render(::Liquid::Context.new({}, assigns, { site: @site }))
  end

end
