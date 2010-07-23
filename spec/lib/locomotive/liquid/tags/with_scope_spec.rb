require 'spec_helper'

describe Locomotive::Liquid::Tags::WithScope do

  it 'should decode options (boolean, interger, ...)' do
    scope = Locomotive::Liquid::Tags::WithScope.new('with_scope', 'active:true price:42 title:\'foo\' hidden:false', ["{% endwith_scope %}"])
    attributes = scope.send(:decode, scope.instance_variable_get(:@attributes))
    attributes['active'].should == true
    attributes['price'].should == 42
    attributes['title'].should == 'foo'
    attributes['hidden'].should == false
  end

  it 'should store attributes in the context' do
    template = ::Liquid::Template.parse("{% with_scope active:true title:'foo' %}{{ with_scope.active }}-{{ with_scope.title }}{% endwith_scope %}")
    text = template.render
    text.should == "true-foo"
  end

end
