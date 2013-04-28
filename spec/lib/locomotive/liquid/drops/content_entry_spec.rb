require 'spec_helper'

describe Locomotive::Liquid::Drops::ContentEntry do

  before(:each) do
    @list = mock('list')
    @list.stubs(:all).returns(true)
    @category = Locomotive::Liquid::Drops::ContentEntry.new(mock('category', projects: @list))
  end

  context '#accessing a has_many relationship' do

    it 'loops through the list' do
      template = %({% for project in category.projects %}{{ project }},{% endfor %})

      @list.expects(:ordered).returns(%w(a b))

      render(template, { 'category' => @category }).should == 'a,b,'
    end

    it 'filters the list' do
      template = %({% with_scope order_by: 'name ASC', active: true %}{% for project in category.projects %}{{ project }},{% endfor %}{% endwith_scope %})

      @list.expects(:filtered).with({ 'active' => true }, ['name', 'ASC']).returns(%w(a b))

      render(template, { 'category' => @category }).should == 'a,b,'
    end

    it 'filters the list and uses the default order' do
      template = %({% with_scope active: true %}{% for project in category.projects %}{{ project }},{% endfor %}{% endwith_scope %})

      @list.expects(:filtered).with({ 'active' => true }, nil).returns(%w(a b))

      render(template, { 'category' => @category }).should == 'a,b,'
    end

  end

  def render(template, assigns = {})
    liquid_context = ::Liquid::Context.new(assigns, {}, {})

    output = ::Liquid::Template.parse(template).render(liquid_context)
    output.gsub(/\n\s{0,}/, '')
  end

end
