require 'spec_helper'

describe Locomotive::Liquid::Drops::Site do

  let(:site)          { FactoryGirl.create(:site) }
  let(:root_page)     { site.pages.root.first }
  let(:about_us_page) { add_page('About us') }
  let(:contact_page)  { add_page('Contact') }

  before { about_us_page && contact_page }

  describe '.pages' do

    let(:template) { '' }
    subject { render_template(template) }

    describe 'display the number of pages' do

      let(:template) { '{{ site.pages.size }}' }
      it { should eq '4' }

    end

    describe 'display the title of all the pages' do

      let(:template) { '{% for page in site.pages %}{{ page.title }} {% endfor %}' }
      it { should eq 'Home page Page not found About us Contact ' }

    end

  end

  def render_template(template = '', assigns = {})
    assigns = { 'site' => site }.merge(assigns)
    Liquid::Template.parse(template).render(::Liquid::Context.new({}, assigns, { site: site }))
  end

  def add_page(title)
    FactoryGirl.create(:page, site: site, parent: root_page, title: title, slug: nil)
  end

end
