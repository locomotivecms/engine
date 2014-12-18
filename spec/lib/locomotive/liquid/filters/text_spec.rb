require 'spec_helper'

describe Locomotive::Liquid::Filters::Text do

  include Locomotive::Liquid::Filters::Text

  it 'transforms a textile input into HTML' do
    expect(textile('This is *my* text.')).to eq "<p>This is <strong>my</strong> text.</p>"
  end

  it 'transforms a markdown input into HTML' do
    expect(markdown('# My title')).to eq "<h1>My title</h1>\n"
  end

  it 'underscores an input' do
    expect(underscore('foo')).to eq 'foo'
    expect(underscore('home page')).to eq 'home_page'
    expect(underscore('My foo Bar')).to eq 'my_foo_bar'
    expect(underscore('foo/bar')).to eq 'foo_bar'
    expect(underscore('foo/bar/index')).to eq 'foo_bar_index'
  end

  it 'dasherizes an input' do
    expect(dasherize('foo')).to eq 'foo'
    expect(dasherize('foo_bar')).to eq 'foo-bar'
    expect(dasherize('foo/bar')).to eq 'foo-bar'
    expect(dasherize('foo/bar/index')).to eq 'foo-bar-index'
  end

  it 'concats strings' do
    expect(concat('foo', 'bar')).to eq 'foobar'
    expect(concat('hello', 'foo', 'bar')).to eq 'hellofoobar'
  end


end
