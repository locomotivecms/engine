require 'spec_helper'

describe Locomotive::Liquid::Drops::Contents do

  before(:each) do
    @site = FactoryGirl.build(:site)
    @content_type = FactoryGirl.build(:content_type, :site => @site, :slug => 'projects')
  end

  it 'retrieves a content type from a slug' do
    @site.content_types.expects(:where).with(:slug => 'projects')
    render_template '{{ contents.projects }}'
  end

  describe '#group_by' do

    it 'orders contents' do
      @site.content_types.stubs(:where).returns([@content_type])
      @content_type.contents.klass.expects(:group_by_category).with(:ordered_contents)
      render_template '{% for group in contents.projects.group_by_category %} {{ group.name }} {% endfor %}'
    end

  end

  def render_template(template = '', assigns = {})
    assigns = {
      'contents' => Locomotive::Liquid::Drops::Contents.new
    }.merge(assigns)

    Liquid::Template.parse(template).render(::Liquid::Context.new({}, assigns, { :site => @site }))
  end

end
