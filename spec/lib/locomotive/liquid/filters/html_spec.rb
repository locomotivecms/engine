require 'spec_helper'

describe Locomotive::Liquid::Filters::Html do

  include Locomotive::Liquid::Filters::Base
  include Locomotive::Liquid::Filters::Html

  before(:each) do
    @context = build_context
  end

  it 'writes the tag to display a rss/atom feed' do
    expect(auto_discovery_link_tag('/foo/bar')).to eq %(
      <link rel="alternate" type="application/rss+xml" title="RSS" href="/foo/bar">
    ).strip

    expect(auto_discovery_link_tag('/foo/bar', 'rel:alternate2', 'type:atom', 'title:Hello world')).to eq %(
      <link rel="alternate2" type="atom" title="Hello world" href="/foo/bar">
    ).strip
  end

  it 'returns an url for a stylesheet file' do
    result = "/sites/000000000000000000000042/theme/stylesheets/main.css"
    expect(stylesheet_url('main.css')).to eq(result)
    expect(stylesheet_url('main')).to eq(result)
    expect(stylesheet_url(nil)).to eq('')
  end

  it 'returnss an url with the checksum' do
    @context.registers.merge!(theme_assets_checksum: { 'stylesheets/main.css' => 42 })
    result = "/sites/000000000000000000000042/theme/stylesheets/main.css?42"
    expect(stylesheet_url('main.css')).to eq(result)
  end

  it 'returns an url for a stylesheet file with folder' do
    result = "/sites/000000000000000000000042/theme/stylesheets/trash/main.css"
    expect(stylesheet_url('trash/main.css')).to eq(result)
  end

  it 'returns an url for a stylesheet file without touching the url that starts with "/"' do
    result = "/trash/main.css"
    expect(stylesheet_url('/trash/main.css')).to eq(result)
    expect(stylesheet_url('/trash/main')).to eq(result)
  end

  it 'returns an url for a stylesheet file without touching the url that starts with "http:"' do
    result = "http://cdn.example.com/trash/main.css"
    expect(stylesheet_url('http://cdn.example.com/trash/main.css')).to eq(result)
    expect(stylesheet_url('http://cdn.example.com/trash/main')).to eq(result)
  end

  it 'returns an url for a stylesheet file without touching the url that starts with "https:"' do
    result = "https://cdn.example.com/trash/main.css"
    expect(stylesheet_url('https://cdn.example.com/trash/main.css')).to eq(result)
    expect(stylesheet_url('https://cdn.example.com/trash/main')).to eq(result)
  end

  it 'returns an url for a stylesheet file with respect to URL-parameters' do
    result = "/sites/000000000000000000000042/theme/stylesheets/main.css?v=42"
    expect(stylesheet_url('main.css?v=42')).to eq(result)
  end

  it 'returns a link tag for a stylesheet file' do
    result = "<link href=\"/sites/000000000000000000000042/theme/stylesheets/main.css\" media=\"screen\" rel=\"stylesheet\" type=\"text/css\">"
    expect(stylesheet_tag('main.css')).to eq(result)
    expect(stylesheet_tag('main')).to eq(result)
    expect(stylesheet_tag(nil)).to eq('')
  end

  it 'returns a link tag for a stylesheet file with folder' do
    result = "<link href=\"/sites/000000000000000000000042/theme/stylesheets/trash/main.css\" media=\"screen\" rel=\"stylesheet\" type=\"text/css\">"
    expect(stylesheet_tag('trash/main.css')).to eq(result)
  end

  it 'returns a link tag for a stylesheet file without touching the url that starts with "/"' do
    result = "<link href=\"/trash/main.css\" media=\"screen\" rel=\"stylesheet\" type=\"text/css\">"
    expect(stylesheet_tag('/trash/main.css')).to eq(result)
    expect(stylesheet_tag('/trash/main')).to eq(result)
  end

  it 'returns a link tag for a stylesheet file without touching the url that starts with "http:"' do
    result = "<link href=\"http://cdn.example.com/trash/main.css\" media=\"screen\" rel=\"stylesheet\" type=\"text/css\">"
    expect(stylesheet_tag('http://cdn.example.com/trash/main.css')).to eq(result)
    expect(stylesheet_tag('http://cdn.example.com/trash/main')).to eq(result)
  end

  it 'returns a link tag for a stylesheet file without touching the url that starts with "https:"' do
    result = "<link href=\"https://cdn.example.com/trash/main.css\" media=\"screen\" rel=\"stylesheet\" type=\"text/css\">"
    expect(stylesheet_tag('https://cdn.example.com/trash/main.css')).to eq(result)
    expect(stylesheet_tag('https://cdn.example.com/trash/main')).to eq(result)
  end

  it 'returns a link tag for a stylesheet stored in Amazon S3' do
    url = 'https://com.citrrus.locomotive.s3.amazonaws.com/sites/42/theme/stylesheets/bootstrap2.css'
    stubs(:asset_url).returns(url)
    result = "<link href=\"#{url}\" media=\"screen\" rel=\"stylesheet\" type=\"text/css\">"
    expect(stylesheet_tag('bootstrap2.css')).to eq(result)
  end

  it 'returns a link tag for a stylesheet file and media attribute set to print' do
    result = "<link href=\"/sites/000000000000000000000042/theme/stylesheets/main.css\" media=\"print\" rel=\"stylesheet\" type=\"text/css\">"
    expect(stylesheet_tag('main.css','print')).to eq(result)
    expect(stylesheet_tag('main','print')).to eq(result)
    expect(stylesheet_tag(nil)).to eq('')
  end

  it 'returns a link tag for a stylesheet file with folder and media attribute set to print' do
    result = "<link href=\"/sites/000000000000000000000042/theme/stylesheets/trash/main.css\" media=\"print\" rel=\"stylesheet\" type=\"text/css\">"
    expect(stylesheet_tag('trash/main.css','print')).to eq(result)
  end

  it 'returns a link tag for a stylesheet file without touching the url that starts with "/" and media attribute set to print' do
    result = "<link href=\"/trash/main.css\" media=\"print\" rel=\"stylesheet\" type=\"text/css\">"
    expect(stylesheet_tag('/trash/main.css','print')).to eq(result)
    expect(stylesheet_tag('/trash/main','print')).to eq(result)
  end

  it 'returns a link tag for a stylesheet file without touching the url that starts with "http:" and media attribute set to print' do
    result = "<link href=\"http://cdn.example.com/trash/main.css\" media=\"print\" rel=\"stylesheet\" type=\"text/css\">"
    expect(stylesheet_tag('http://cdn.example.com/trash/main.css','print')).to eq(result)
    expect(stylesheet_tag('http://cdn.example.com/trash/main','print')).to eq(result)
  end

  it 'returns a link tag for a stylesheet file without touching the url that starts with "https:" and media attribute set to print' do
    result = "<link href=\"https://cdn.example.com/trash/main.css\" media=\"print\" rel=\"stylesheet\" type=\"text/css\">"
    expect(stylesheet_tag('https://cdn.example.com/trash/main.css','print')).to eq(result)
    expect(stylesheet_tag('https://cdn.example.com/trash/main','print')).to eq(result)
  end

  it 'returns an url for a javascript file' do
    result = "/sites/000000000000000000000042/theme/javascripts/main.js"
    expect(javascript_url('main.js')).to eq(result)
    expect(javascript_url('main')).to eq(result)
    expect(javascript_url(nil)).to eq('')
  end

  it 'returns an url for a javascript file with folder' do
    result = "/sites/000000000000000000000042/theme/javascripts/trash/main.js"
    expect(javascript_url('trash/main.js')).to eq(result)
    expect(javascript_url('trash/main')).to eq(result)
  end

  it 'returns an url for a javascript file without touching the url that starts with "/"' do
    result = "/trash/main.js"
    expect(javascript_url('/trash/main.js')).to eq(result)
    expect(javascript_url('/trash/main')).to eq(result)
  end

  it 'returns an url for a javascript file without touching the url that starts with "http:"' do
    result = "http://cdn.example.com/trash/main.js"
    expect(javascript_url('http://cdn.example.com/trash/main.js')).to eq(result)
    expect(javascript_url('http://cdn.example.com/trash/main')).to eq(result)
  end

  it 'returns an url for a javascript file without touching the url that starts with "https:"' do
    result = "https://cdn.example.com/trash/main.js"
    expect(javascript_url('https://cdn.example.com/trash/main.js')).to eq(result)
    expect(javascript_url('https://cdn.example.com/trash/main')).to eq(result)
  end

  it 'returns an url for a javascript file with respect to URL-parameters' do
    result = "/sites/000000000000000000000042/theme/javascripts/main.js?v=42"
    expect(javascript_url('main.js?v=42')).to eq(result)
  end

  it 'returns a script tag for a javascript file' do
    result = %{<script src="/sites/000000000000000000000042/theme/javascripts/main.js" type="text/javascript" ></script>}
    expect(javascript_tag('main.js')).to eq(result)
    expect(javascript_tag('main')).to eq(result)
    expect(javascript_tag(nil)).to eq('')
  end

  it 'returns a script tag for a javascript file with folder' do
    result = %{<script src="/sites/000000000000000000000042/theme/javascripts/trash/main.js" type="text/javascript" ></script>}
    expect(javascript_tag('trash/main.js')).to eq(result)
    expect(javascript_tag('trash/main')).to eq(result)
  end

  it 'returns a script tag for a javascript file without touching the url that starts with "/"' do
    result = %{<script src="/trash/main.js" type="text/javascript" ></script>}
    expect(javascript_tag('/trash/main.js')).to eq(result)
    expect(javascript_tag('/trash/main')).to eq(result)
  end

  it 'returns a script tag for a javascript file without touching the url that starts with "http:"' do
    result = %{<script src="http://cdn.example.com/trash/main.js" type="text/javascript" ></script>}
    expect(javascript_tag('http://cdn.example.com/trash/main.js')).to eq(result)
    expect(javascript_tag('http://cdn.example.com/trash/main')).to eq(result)
  end

  it 'returns a script tag for a javascript file without touching the url that starts with "https:"' do
    result = %{<script src="https://cdn.example.com/trash/main.js" type="text/javascript" ></script>}
    expect(javascript_tag('https://cdn.example.com/trash/main.js')).to eq(result)
    expect(javascript_tag('https://cdn.example.com/trash/main')).to eq(result)
  end

  it 'returns a script tag for a javascript file with "defer" option' do
    result = %{<script src="https://cdn.example.com/trash/main.js" type="text/javascript" defer="defer" ></script>}
    expect(javascript_tag('https://cdn.example.com/trash/main.js', ['defer:defer'])).to eq(result)
  end

  it 'returns an image tag for a given theme file without parameters' do
    expect(theme_image_tag('foo.jpg')).to eq("<img src=\"/sites/000000000000000000000042/theme/images/foo.jpg\" >")
  end

  it 'returns an image tag for a given theme file with size' do
    expect(theme_image_tag('foo.jpg', 'width:100', 'height:100')).to eq("<img src=\"/sites/000000000000000000000042/theme/images/foo.jpg\" height=\"100\" width=\"100\" >")
  end

  it 'returns an image tag without parameters' do
    expect(image_tag('foo.jpg')).to eq("<img src=\"foo.jpg\" >")
  end

  it 'returns an image tag with size' do
    expect(image_tag('foo.jpg', 'width:100', 'height:50')).to eq("<img src=\"foo.jpg\" height=\"50\" width=\"100\" >")
  end

  it 'returns a flash tag without parameters' do
    expect(flash_tag('foo.flv')).to eq(%{
            <object>
              <param name="movie" value="foo.flv">
              <embed src="foo.flv">
              </embed>
            </object>
    }.strip)
  end

  it 'returns a flash tag with size' do
    expect(flash_tag('foo.flv', 'width:100', 'height:50')).to eq(%{
            <object height=\"50\" width=\"100\">
              <param name="movie" value="foo.flv">
              <embed src="foo.flv" height=\"50\" width=\"100\">
              </embed>
            </object>
    }.strip)
  end

  def build_context
    klass = Class.new
    klass.class_eval do
      def registers
        @registers ||= {
          site: FactoryGirl.build(:site, id: fake_bson_id(42)),
          theme_assets_checksum: {},
          asset_host: TimestampAssetHost.new
        }
      end

      def fake_bson_id(id)
        BSON::ObjectId.from_string(id.to_s.rjust(24, '0'))
      end
    end
    klass.new
  end

end
