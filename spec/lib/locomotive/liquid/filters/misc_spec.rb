require 'spec_helper'

describe Locomotive::Liquid::Filters::Misc do

  include Locomotive::Liquid::Filters::Misc

  it 'should underscore an input' do
    underscore('foo').should == 'foo'
    underscore('home page').should == 'home_page'
    underscore('My foo Bar').should == 'my_foo_bar'
    underscore('foo/bar').should == 'foo_bar'
    underscore('foo/bar/index').should == 'foo_bar_index'
  end

  it 'should dasherize an input' do
    dasherize('foo').should == 'foo'
    dasherize('foo_bar').should == 'foo-bar'
    dasherize('foo/bar').should == 'foo-bar'
    dasherize('foo/bar/index').should == 'foo-bar-index'
  end

  it 'should concat strings' do
    concat('foo', 'bar').should == 'foobar'
    concat('hello', 'foo', 'bar').should == 'hellofoobar'
  end

  it 'should return the input string every n occurences' do
    modulo('foo', 0, 3).should == ''
    modulo('foo', 1, 3).should == ''
    modulo('foo', 2, 3).should == 'foo'
    modulo('foo', 3, 3).should == ''
    modulo('foo', 4, 3).should == ''
    modulo('foo', 5, 3).should == 'foo'
  end

end
