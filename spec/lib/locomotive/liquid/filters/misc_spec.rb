require 'spec_helper'

describe Locomotive::Liquid::Filters::Misc do

  include Locomotive::Liquid::Filters::Misc

  it 'underscores an input' do
    underscore('foo').should == 'foo'
    underscore('home page').should == 'home_page'
    underscore('My foo Bar').should == 'my_foo_bar'
    underscore('foo/bar').should == 'foo_bar'
    underscore('foo/bar/index').should == 'foo_bar_index'
  end

  it 'dasherizes an input' do
    dasherize('foo').should == 'foo'
    dasherize('foo_bar').should == 'foo-bar'
    dasherize('foo/bar').should == 'foo-bar'
    dasherize('foo/bar/index').should == 'foo-bar-index'
  end

  it 'concats strings' do
    concat('foo', 'bar').should == 'foobar'
    concat('hello', 'foo', 'bar').should == 'hellofoobar'
  end

  it 'returns the input string every n occurences' do
    modulo('foo', 0, 3).should == ''
    modulo('foo', 1, 3).should == ''
    modulo('foo', 2, 3).should == 'foo'
    modulo('foo', 3, 3).should == ''
    modulo('foo', 4, 3).should == ''
    modulo('foo', 5, 3).should == 'foo'
  end

  it 'returns default values if the input is empty' do
    default('foo', 42).should == 'foo'
    default('', 42).should == 42
    default(nil, 42).should == 42
  end

end
