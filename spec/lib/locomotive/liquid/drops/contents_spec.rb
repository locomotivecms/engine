require 'spec_helper'

describe Locomotive::Liquid::Drops::Contents do

  before(:each) do
    # Reload the file (needed for spork)
    load File.join(Rails.root, 'lib', 'locomotive', 'liquid', 'drops', 'contents.rb')

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

  describe Locomotive::Liquid::Drops::ProxyCollection do

    before(:each) do
      populate_content_type
      @proxy_collection = Locomotive::Liquid::Drops::ProxyCollection.new(@content_type)
      @proxy_collection.context = {}
    end

    it 'provides its size like an Array' do
      @proxy_collection.size.should == @proxy_collection.length
    end

    it 'can be enumerated using each_with_index' do
      @proxy_collection.each_with_index do |item, index|
        item._slug.should == "item#{index + 1}"
      end
    end

  end

  def render_template(template = '', assigns = {})
    assigns = {
      'contents' => Locomotive::Liquid::Drops::Contents.new
    }.merge(assigns)

    Liquid::Template.parse(template).render(::Liquid::Context.new({}, assigns, { :site => @site }))
  end

  def populate_content_type
    @content_type.order_by = :_slug
    @content_type.contents.build(:_slug => 'item1')
    @content_type.contents.build(:_slug => 'item2')
    @content_type.contents.build(:_slug => 'item3')
  end

end
