require 'spec_helper'

describe Locomotive::Liquid::Tags::LinkTo do

  before(:each) do
    I18n.locale = :en
    @site = FactoryGirl.create("test site")
    
    @ctype = FactoryGirl.build(:content_type, site: @site, name: "Projects")
    @ctype.entries_custom_fields.build(name: "name", type: "string", label: "name")
    @ctype.save!
    @ctype.entries.create!(name: "My fancy project")
    
    defaults = {site: @site, templatized: true, target_klass_name: @ctype.klass_with_custom_fields(:entries).to_s}
    @a = FactoryGirl.create(:sub_page, slug: "department-a")
    @b = FactoryGirl.create(:sub_page, slug: "department-b")
    FactoryGirl.create(:sub_page, defaults.merge(parent: @a, title: "Page A", slug: "page-a-slug", handle: 'page-a', raw_template: "{{ name }} from Page A"))
    FactoryGirl.create(:sub_page, defaults.merge(parent: @b, title: "Page B", slug: "page-b-slug", handle: 'page-b', raw_template: "{{ name }} from Page B"))
  end

  it 'renders using the specified page namespace' do
    render('page-a').should == ' <a href="/department-a/my-fancy-project">My fancy project</a> '
    render('page-b').should == ' <a href="/department-b/my-fancy-project">My fancy project</a> '
  end

  def render(handle)
    liquid_context = ::Liquid::Context.new({}, {'contents' => Locomotive::Liquid::Drops::ContentTypes.new}, {site: @site})

    output = Liquid::Template.parse("{% for project in contents.projects %} {% link_to project, with: #{handle} %} {% endfor %}").render(liquid_context)
    output.gsub(/\n\s{0,}/, '')
  end

end
