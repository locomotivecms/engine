require 'spec_helper'

describe Locomotive::Liquid::Filters::Text do

  include Locomotive::Liquid::Filters::Text

  it 'transforms a textile input into HTML' do
    textile('This is *my* text.').should == "<p>This is <strong>my</strong> text.</p>"
  end

  it 'transforms a markdown input into HTML' do
    markdown('# My title').should == "<h1>My title</h1>\n"
  end

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


end
