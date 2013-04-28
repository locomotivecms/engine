require 'spec_helper'

describe Locomotive::Extensions::Page::Render do

  before(:each) do
    Locomotive::Site.any_instance.stubs(:create_default_pages!).returns(true)
    @site = FactoryGirl.create(:site)
    @home = FactoryGirl.create(:page, site: @site, raw_template:     """
    Hello world
    {% block header %}Home header{% endblock %}
    {% block main %}My home page{% endblock %}
    """)
  end

  it 'renders the home page' do
    render(@home).should == 'Hello world, Home header, My home page'
  end

  describe '#inheritance' do

    before(:each) do
      @inner = FactoryGirl.create(:sub_page, slug: 'innerpage', site: @site, raw_template:       """
      {% extends parent %}
      {% block header %}Inner header{% endblock %}
      {% block main %}Inner page{% endblock %}
      """)
      @contact = FactoryGirl.create(:sub_page, slug: 'contact', site: @site, raw_template:       """
      {% extends 'innerpage' %}
      {% block header %}Contact header{% endblock %}
      {% block main %}Contact page{% endblock %}
      """)
      @about = FactoryGirl.create(:sub_page, slug: 'about', site: @site, raw_template:       """
      {% extends 'innerpage' %}
      {% block main %}About page{% endblock %}
      """)
    end

    it 'renders the inner page' do
      render(@inner).should == 'Hello world, Inner header, Inner page'
    end

    it 'renders the contact page' do
      render(@contact).should == 'Hello world, Contact header, Contact page'
    end

    it 'renders the about page' do
      render(@about).should == 'Hello world, Inner header, About page'
    end

    context 'when parent page got modified' do

      before(:each) do
        @home.raw_template = """
        Hello world (UPDATED)
        {% block header %}Home header (UPDATED){% endblock %}
        {% block main %}My home page (UPDATED){% endblock %}
        """
        @home.save & @home.reload
        @inner    = Locomotive::Page.find(@inner._id)
        @contact  = Locomotive::Page.find(@contact._id)
        @about    = Locomotive::Page.find(@about._id)
      end

      it 'reflects changes on the inner page' do
        render(@inner).should == 'Hello world (UPDATED), Inner header, Inner page'
      end

      it 'reflects changes on the contact page' do
        render(@contact).should == 'Hello world (UPDATED), Contact header, Contact page'
      end

      it 'reflects changes on the about page' do
        render(@about).should == 'Hello world (UPDATED), Inner header, About page'
      end

    end

  end

  def render(page)
    page.render(::Liquid::Context.new({}, {}, {}, false)).strip.gsub(/(\s{2,})/, ', ')
  end

end