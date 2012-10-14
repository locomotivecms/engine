require 'spec_helper'

describe Locomotive::Liquid::Filters::Html do

  include Locomotive::Liquid::Filters::Base
  include Locomotive::Liquid::Filters::Html

  before(:each) do
    @context = build_context
  end

  it 'writes the tag to display a rss/atom feed' do
    auto_discovery_link_tag('/foo/bar').should == %(
      <link rel="alternate" type="application/rss+xml" title="RSS" href="/foo/bar">
    ).strip

    auto_discovery_link_tag('/foo/bar', 'rel:alternate2', 'type:atom', 'title:Hello world').should == %(
      <link rel="alternate2" type="atom" title="Hello world" href="/foo/bar">
    ).strip
  end

  it 'should return a url for a stylesheet file' do
    result = "/sites/000000000000000000000042/theme/stylesheets/main.css"
    stylesheet_url('main.css').should == result
    stylesheet_url('main').should == result
    stylesheet_url(nil).should == ''
  end

  it 'should return a url for a stylesheet file with folder' do
    result = "/sites/000000000000000000000042/theme/stylesheets/trash/main.css"
    stylesheet_url('trash/main.css').should == result
  end

  it 'should return a url for a stylesheet file without touching the url that starts with "/"' do
    result = "/trash/main.css"
    stylesheet_url('/trash/main.css').should == result
    stylesheet_url('/trash/main').should == result
  end

  it 'should return a url for a stylesheet file without touching the url that starts with "http:"' do
    result = "http://cdn.example.com/trash/main.css"
    stylesheet_url('http://cdn.example.com/trash/main.css').should == result
    stylesheet_url('http://cdn.example.com/trash/main').should == result
  end

  it 'should return a url for a stylesheet file without touching the url that starts with "https:"' do
    result = "https://cdn.example.com/trash/main.css"
    stylesheet_url('https://cdn.example.com/trash/main.css').should == result
    stylesheet_url('https://cdn.example.com/trash/main').should == result
  end

  it 'should return a link tag for a stylesheet file' do
    result = "<link href=\"/sites/000000000000000000000042/theme/stylesheets/main.css\" media=\"screen\" rel=\"stylesheet\" type=\"text/css\">"
    stylesheet_tag('main.css').should == result
    stylesheet_tag('main').should == result
    stylesheet_tag(nil).should == ''
  end

  it 'should return a link tag for a stylesheet file with folder' do
    result = "<link href=\"/sites/000000000000000000000042/theme/stylesheets/trash/main.css\" media=\"screen\" rel=\"stylesheet\" type=\"text/css\">"
    stylesheet_tag('trash/main.css').should == result
  end

  it 'should return a link tag for a stylesheet file without touching the url that starts with "/"' do
    result = "<link href=\"/trash/main.css\" media=\"screen\" rel=\"stylesheet\" type=\"text/css\">"
    stylesheet_tag('/trash/main.css').should == result
    stylesheet_tag('/trash/main').should == result
  end

  it 'should return a link tag for a stylesheet file without touching the url that starts with "http:"' do
    result = "<link href=\"http://cdn.example.com/trash/main.css\" media=\"screen\" rel=\"stylesheet\" type=\"text/css\">"
    stylesheet_tag('http://cdn.example.com/trash/main.css').should == result
    stylesheet_tag('http://cdn.example.com/trash/main').should == result
  end

  it 'should return a link tag for a stylesheet file without touching the url that starts with "https:"' do
    result = "<link href=\"https://cdn.example.com/trash/main.css\" media=\"screen\" rel=\"stylesheet\" type=\"text/css\">"
    stylesheet_tag('https://cdn.example.com/trash/main.css').should == result
    stylesheet_tag('https://cdn.example.com/trash/main').should == result
  end

  it 'should return a link tag for a stylesheet file and media attribute set to print' do
    result = "<link href=\"/sites/000000000000000000000042/theme/stylesheets/main.css\" media=\"print\" rel=\"stylesheet\" type=\"text/css\">"
    stylesheet_tag('main.css','print').should == result
    stylesheet_tag('main','print').should == result
    stylesheet_tag(nil).should == ''
  end

  it 'should return a link tag for a stylesheet file with folder and media attribute set to print' do
    result = "<link href=\"/sites/000000000000000000000042/theme/stylesheets/trash/main.css\" media=\"print\" rel=\"stylesheet\" type=\"text/css\">"
    stylesheet_tag('trash/main.css','print').should == result
  end

  it 'should return a link tag for a stylesheet file without touching the url that starts with "/" and media attribute set to print' do
    result = "<link href=\"/trash/main.css\" media=\"print\" rel=\"stylesheet\" type=\"text/css\">"
    stylesheet_tag('/trash/main.css','print').should == result
    stylesheet_tag('/trash/main','print').should == result
  end

  it 'should return a link tag for a stylesheet file without touching the url that starts with "http:" and media attribute set to print' do
    result = "<link href=\"http://cdn.example.com/trash/main.css\" media=\"print\" rel=\"stylesheet\" type=\"text/css\">"
    stylesheet_tag('http://cdn.example.com/trash/main.css','print').should == result
    stylesheet_tag('http://cdn.example.com/trash/main','print').should == result
  end

  it 'should return a link tag for a stylesheet file without touching the url that starts with "https:" and media attribute set to print' do
    result = "<link href=\"https://cdn.example.com/trash/main.css\" media=\"print\" rel=\"stylesheet\" type=\"text/css\">"
    stylesheet_tag('https://cdn.example.com/trash/main.css','print').should == result
    stylesheet_tag('https://cdn.example.com/trash/main','print').should == result
  end

  it 'should return a url for a javascript file' do
    result = "/sites/000000000000000000000042/theme/javascripts/main.js"
    javascript_url('main.js').should == result
    javascript_url('main').should == result
    javascript_url(nil).should == ''
  end

  it 'should return a url for a javascript file with folder' do
    result = "/sites/000000000000000000000042/theme/javascripts/trash/main.js"
    javascript_url('trash/main.js').should == result
    javascript_url('trash/main').should == result
  end

  it 'should return a url for a javascript file without touching the url that starts with "/"' do
    result = "/trash/main.js"
    javascript_url('/trash/main.js').should == result
    javascript_url('/trash/main').should == result
  end

  it 'should return a url for a javascript file without touching the url that starts with "http:"' do
    result = "http://cdn.example.com/trash/main.js"
    javascript_url('http://cdn.example.com/trash/main.js').should == result
    javascript_url('http://cdn.example.com/trash/main').should == result
  end

  it 'should return a url for a javascript file without touching the url that starts with "https:"' do
    result = "https://cdn.example.com/trash/main.js"
    javascript_url('https://cdn.example.com/trash/main.js').should == result
    javascript_url('https://cdn.example.com/trash/main').should == result
  end

  it 'should return a script tag for a javascript file' do
    result = %{<script src="/sites/000000000000000000000042/theme/javascripts/main.js" type="text/javascript"></script>}
    javascript_tag('main.js').should == result
    javascript_tag('main').should == result
    javascript_tag(nil).should == ''
  end

  it 'should return a script tag for a javascript file with folder' do
    result = %{<script src="/sites/000000000000000000000042/theme/javascripts/trash/main.js" type="text/javascript"></script>}
    javascript_tag('trash/main.js').should == result
    javascript_tag('trash/main').should == result
  end

  it 'should return a script tag for a javascript file without touching the url that starts with "/"' do
    result = %{<script src="/trash/main.js" type="text/javascript"></script>}
    javascript_tag('/trash/main.js').should == result
    javascript_tag('/trash/main').should == result
  end

  it 'should return a script tag for a javascript file without touching the url that starts with "http:"' do
    result = %{<script src="http://cdn.example.com/trash/main.js" type="text/javascript"></script>}
    javascript_tag('http://cdn.example.com/trash/main.js').should == result
    javascript_tag('http://cdn.example.com/trash/main').should == result
  end

  it 'should return a script tag for a javascript file without touching the url that starts with "https:"' do
    result = %{<script src="https://cdn.example.com/trash/main.js" type="text/javascript"></script>}
    javascript_tag('https://cdn.example.com/trash/main.js').should == result
    javascript_tag('https://cdn.example.com/trash/main').should == result
  end

  it 'should return an image tag for a given theme file without parameters' do
    theme_image_tag('foo.jpg').should == "<img src=\"/sites/000000000000000000000042/theme/images/foo.jpg\" >"
  end

  it 'should return an image tag for a given theme file with size' do
    theme_image_tag('foo.jpg', 'width:100', 'height:100').should == "<img src=\"/sites/000000000000000000000042/theme/images/foo.jpg\" height=\"100\" width=\"100\" >"
  end

  it 'should return an image tag without parameters' do
    image_tag('foo.jpg').should == "<img src=\"foo.jpg\" >"
  end

  it 'should return an image tag with size' do
    image_tag('foo.jpg', 'width:100', 'height:50').should == "<img src=\"foo.jpg\" height=\"50\" width=\"100\" >"
  end

  it 'should return a flash tag without parameters' do
    flash_tag('foo.flv').should == %{
            <object>
              <param name="movie" value="foo.flv">
              <embed src="foo.flv">
              </embed>
            </object>
    }.strip
  end

  it 'should return a flash tag with size' do
    flash_tag('foo.flv', 'width:100', 'height:50').should == %{
            <object height=\"50\" width=\"100\">
              <param name="movie" value="foo.flv">
              <embed src="foo.flv" height=\"50\" width=\"100\">
              </embed>
            </object>
    }.strip
  end

  def build_context
    klass = Class.new
    klass.class_eval do
      def registers
        { :site => FactoryGirl.build(:site, :id => fake_bson_id(42)) }
      end

      def fake_bson_id(id)
        BSON::ObjectId(id.to_s.rjust(24, '0'))
      end
    end
    klass.new
  end

end
