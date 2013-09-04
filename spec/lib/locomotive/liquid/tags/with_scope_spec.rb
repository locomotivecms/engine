require 'spec_helper'

describe Locomotive::Liquid::Tags::WithScope do

  it 'decodes basic options (boolean, integer, ...)' do
    scope   = Locomotive::Liquid::Tags::WithScope.new('with_scope', "active: true, price: 42, title: 'foo', hidden: false", ["{% endwith_scope %}"], {})
    options = decode_options(scope)
    options['active'].should == true
    options['price'].should == 42
    options['title'].should == 'foo'
    options['hidden'].should == false
  end

  it 'decodes regexps' do
    scope   = Locomotive::Liquid::Tags::WithScope.new('with_scope', 'title: /Like this one|or this one/', ["{% endwith_scope %}"], {})
    options = decode_options(scope)
    options[:title].should == /Like this one|or this one/
  end

  it 'decodes context variable' do
    scope   = Locomotive::Liquid::Tags::WithScope.new('with_scope', 'category: params.type', ["{% endwith_scope %}"], {})
    options = decode_options(scope, { 'params' => { 'type' => 'posts' } })
    options[:category].should == 'posts'
  end

  it 'allows order_by option' do
    scope   = Locomotive::Liquid::Tags::WithScope.new('with_scope', 'order_by:\'name DESC\'', ["{% endwith_scope %}"], {})
    options = decode_options(scope)
    options['order_by'].should == 'name DESC'
  end

  it 'stores attributes in the context' do
    template  = ::Liquid::Template.parse("{% with_scope active:true, title:'foo' %}{{ with_scope.active }}-{{ with_scope.title }}{% endwith_scope %}")
    text      = template.render
    text.should == 'true-foo'
  end

  it 'allows a variable condition inside a loop' do
    template  = ::Liquid::Template.parse("{%for i in (1..3)%}{% with_scope number: i %}{{ with_scope.number}}{% endwith_scope %}{%endfor%}")
    text      = template.render
    text.should == '123'
  end

  it 'replaces _permalink by _slug' do
    template  = ::Liquid::Template.parse("{% with_scope _permalink: 'foo' %}{{ with_scope._slug }}{% endwith_scope %}")
    text      = template.render
    text.should == 'foo'
  end

  describe "advanced queries thanks to h4s" do

    it 'decodes criteria with gt and lt' do
      scope   = Locomotive::Liquid::Tags::WithScope.new('with_scope', 'price.gt:42.0, price.lt:50', ["{% endwith_scope %}"], {})
      options = decode_options(scope)
      options[:price.gt].should == 42.0
      options[:price.lt].should == 50
    end

  end

  def decode_options(tag, assigns = {})
    context   = ::Liquid::Context.new(assigns)
    arguments = tag.instance_variable_get(:@arguments)
    tag.send(:decode, *arguments.interpolate(context))
  end

end
