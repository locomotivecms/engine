require 'spec_helper'

describe Locomotive::Liquid::Tags::Nav do

  before(:each) do
    @home = FactoryGirl.build(:page)
    home_children = [
      Locomotive::Page.new(title: 'Child #1', fullpath: 'child_1', slug: 'child_1', published: true),
      Locomotive::Page.new(title: 'Child #2', fullpath: 'child_2', slug: 'child_2', published: true)
    ]
    @home.stubs(:children_with_minimal_attributes).returns(home_children)
    @home.stubs(:children).returns(home_children)

    other_children = [
      Locomotive::Page.new(title: 'Child #2.1', fullpath: 'child_2/sub_child_1', slug: 'sub_child_1', published: true),
      Locomotive::Page.new(title: 'Child #2.2', fullpath: 'child_2/sub_child_2', slug: 'sub_child_2', published: true),
      Locomotive::Page.new(title: 'Unpublished #2.2', fullpath: 'child_2/sub_child_unpublishd_2', slug: 'sub_child_unpublished_2', published: false),
      Locomotive::Page.new(title: 'Templatized #2.3', fullpath: 'child_2/sub_child_template_3',   slug: 'sub_child_template_3',    published: true,   templatized: true),
      Locomotive::Page.new(title: 'Unlisted    #2.4', fullpath: 'child_2/sub_child_unlisted_4',   slug: 'sub_child_unlisted_4',    published: true,   listed: false)
    ]
    @home.children.last.stubs(:children_with_minimal_attributes).returns(other_children)
    @home.children.last.stubs(:children).returns(other_children)

    pages = [@home]
    pages.stubs(:root).returns(pages)
    pages.stubs(:minimal_attributes).returns(pages) # iso
    @site = FactoryGirl.build(:site, locales: %w(en fr))
    @site.stubs(:pages).returns(pages)
  end

  context '#rendering' do

    it 'renders from site' do
      expect(render_nav).to eq('<nav id="nav"><ul><li id="child-1-link" class="link first"><a href="/child_1">Child #1</a></li><li id="child-2-link" class="link last"><a href="/child_2">Child #2</a></li></ul></nav>')
    end

    it 'renders from page' do
      expect(render_nav('page')).to eq('<nav id="nav"><ul><li id="child-1-link" class="link first"><a href="/child_1">Child #1</a></li><li id="child-2-link" class="link last"><a href="/child_2">Child #2</a></li></ul></nav>')
    end

    it 'renders from parent' do
      (page = @home.children.last.children.first).stubs(:parent).returns(@home.children.last)
      output = render_nav 'parent', { page: page }
      expect(output).to eq('<nav id="nav"><ul><li id="sub-child-1-link" class="link on first"><a href="/child_2/sub_child_1">Child #2.1</a></li><li id="sub-child-2-link" class="link last"><a href="/child_2/sub_child_2">Child #2.2</a></li></ul></nav>')
    end

    it 'renders children to depth' do
      output = render_nav('site', {}, 'depth: 2')

      expect(output).to match /<nav id="nav">/
      expect(output).to match /<ul>/
      expect(output).to match /<li id="child-1-link" class="link first">/
      expect(output).to match /<\/a><ul id="nav-child-2" class="">/
      expect(output).to match /<li id="sub-child-1-link" class="link first">/
      expect(output).to match /<li id="sub-child-2-link" class="link last">/
      expect(output).to match /<\/a><\/li><\/ul><\/li><\/ul><\/nav>/
    end

    it 'does not render templatized pages' do
      output = render_nav('site', {}, 'depth: 2')

      expect(output).to_not match /sub-child-template-3/
    end

    it 'does not render unpublished pages' do
      output = render_nav('site', {}, 'depth: 2')

      expect(output).to_not match /sub-child-unpublished-3/
    end

    it 'does not render unlisted pages' do
      output = render_nav('site', {}, 'depth: 2')

      expect(output).to_not match /sub-child-unlisted-3/
    end

    it 'does not render nested excluded pages' do
      output = render_nav('site', {}, 'depth: 2, exclude: "child_2/sub_child_2"')

      expect(output).to     match /<li id="child-2-link" class="link last">/
      expect(output).to     match /<li id="sub-child-1-link" class="link first last">/
      expect(output).to_not match /sub-child-2/

      output = render_nav('site', {}, 'depth: 2, exclude: "child_2"')

      expect(output).to     match /<li id="child-1-link" class="link first last">/
      expect(output).to_not match /child-2/
      expect(output).to_not match /sub-child/
    end

    it 'adds an icon before the link' do
      expect(render_nav('site', {}, 'icon: true')).to match /<li id="child-1-link" class="link first"><a href="\/child_1"><span><\/span>Child #1<\/a>/
      expect(render_nav('site', {}, 'icon: before')).to match /<li id="child-1-link" class="link first"><a href="\/child_1"><span><\/span>Child #1<\/a>/
    end

    it 'adds an icon after the link' do
      expect(render_nav('site', {}, 'icon: after')).to match /<li id="child-1-link" class="link first"><a href="\/child_1">Child #1<span><\/span><\/a><\/li>/
    end

    it 'renders a snippet for the title' do
      expect(render_nav('site', {}, 'snippet: "-{{page.title}} {{ foo.png | theme_image_tag }}-"')).to match /<li id="child-1-link" class="link first"><a href="\/child_1">-Child #1 <img src=\"\" >-<\/a><\/li>/
    end

    it 'assigns a different dom id' do
      expect(render_nav('site', {}, 'id: "main-nav"')).to match /<nav id="main-nav">/
    end

    it 'assigns a class' do
      expect(render_nav('site', {}, 'class: "nav"')).to match /<nav id="nav" class="nav">/
    end

    it 'assigns a class other than "on" for a selected item' do
      (page = @home.children.last.children.first).stubs(:parent).returns(@home.children.last)
      output = render_nav 'parent', { page: page }, 'active_class: "active"'
      expect(output).to match /<li id="sub-child-1-link" class="link active first">/
    end

    it 'excludes entries based on a regexp' do
      expect(render_nav('page', {}, 'exclude: "child_1"')).to eq('<nav id="nav"><ul><li id="child-2-link" class="link first last"><a href="/child_2">Child #2</a></li></ul></nav>')
    end

    it 'does not render the parent ul' do
      expect(render_nav('site', {}, 'no_wrapper: true')).to_not match /<ul id="nav">/
    end

    it 'localizes the links' do
      I18n.with_locale('fr') do
        expect(render_nav).to eq('<nav id="nav"><ul><li id="child-1-link" class="link first"><a href="/fr/child_1">Child #1</a></li><li id="child-2-link" class="link last"><a href="/fr/child_2">Child #2</a></li></ul></nav>')
      end
    end

  end

  def render_nav(source = 'site', registers = {}, template_option = '')
    registers = { site: @site, page: @home }.merge(registers)
    liquid_context = ::Liquid::Context.new({}, {}, registers)

    output = Liquid::Template.parse("{% nav #{source} #{template_option} %}").render(liquid_context)
    output.gsub(/\n\s{0,}/, '')
  end

end
