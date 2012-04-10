require 'spec_helper'

describe Locomotive::Liquid::Tags::Find do

  it 'is valid if the 2 arguments are present' do
    lambda do
      Locomotive::Liquid::Tags::Find.new('find', 'projects, params.permalink', [], {})
    end.should_not raise_error
  end

  it 'is not valid if one of the 2 arguments is missing' do
    lambda do
      Locomotive::Liquid::Tags::Find.new('find', 'projects', [], {})
    end.should raise_error
  end

  # it 'tests' do
  #   tag = Locomotive::Liquid::Tags::Find.new('find', 'projects, params.permalink', [], {})
  #   puts tag.inspect
  #   # attributes = scope.send(:decode, scope.instance_variable_get(:@attributes), ::Liquid::Context.new)
  #   # attributes['active'].should == true
  #   # attributes['price'].should == 42
  #   # attributes['title'].should == 'foo'
  #   # attributes['hidden'].should == false
  # end

  # it 'decodes more complex options' do
  #   scope = Locomotive::Liquid::Tags::WithScope.new('with_scope', 'price.gt:42.0 price.lt:50', ["{% endwith_scope %}"], {})
  #   attributes = scope.send(:decode, scope.instance_variable_get(:@attributes), ::Liquid::Context.new)
  #   attributes['price.gt'].should == 42.0
  #   attributes['price.lt'].should == 50
  # end
  #
  # it 'decodes context variable' do
  #   scope = Locomotive::Liquid::Tags::WithScope.new('with_scope', 'category: params.type', ["{% endwith_scope %}"], {})
  #   attributes = scope.send(:decode, scope.instance_variable_get(:@attributes), ::Liquid::Context.new({ 'params' => { 'type' => 'posts' } }))
  #   attributes['category'].should == 'posts'
  # end
  #
  # it 'allows order_by option' do
  #   scope = Locomotive::Liquid::Tags::WithScope.new('with_scope', 'order_by:\'name DESC\'', ["{% endwith_scope %}"], {})
  #   attributes = scope.send(:decode, scope.instance_variable_get(:@attributes), ::Liquid::Context.new)
  #   attributes['order_by'].should == 'name DESC'
  # end
  #
  # it 'stores attributes in the context' do
  #   template = ::Liquid::Template.parse("{% with_scope active:true title:'foo' %}{{ with_scope.active }}-{{ with_scope.title }}{% endwith_scope %}")
  #   text = template.render
  #   text.should == "true-foo"
  # end

end
