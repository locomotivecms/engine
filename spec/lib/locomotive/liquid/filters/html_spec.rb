require 'spec_helper'

describe Locomotive::Liquid::Filters::Html do

  include Locomotive::Liquid::Filters::Html

  before(:each) do
    @context = build_context
  end

  it 'should return a link tag for a stylesheet file' do
    result = "<link href=\"/sites/000000000000000000000042/theme/stylesheets/main.css\" media=\"screen\" rel=\"stylesheet\" type=\"text/css\" />"
    stylesheet_tag('main.css').should == result
    stylesheet_tag('main').should == result
    stylesheet_tag(nil).should == ''
  end

  it 'should return a link tag for a stylesheet file with folder' do
    result = "<link href=\"/sites/000000000000000000000042/theme/stylesheets/trash/main.css\" media=\"screen\" rel=\"stylesheet\" type=\"text/css\" />"
    stylesheet_tag('trash/main.css').should == result
  end

  it 'should return a link tag for a stylesheet file without touching the url' do
    result = "<link href=\"/trash/main.css\" media=\"screen\" rel=\"stylesheet\" type=\"text/css\" />"
    stylesheet_tag('/trash/main.css').should == result
    stylesheet_tag('/trash/main').should == result
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

  it 'should return a script tag for a javascript file without touching the url' do
    result = %{<script src="/trash/main.js" type="text/javascript"></script>}
    javascript_tag('/trash/main.js').should == result
    javascript_tag('/trash/main').should == result
  end
  
  it 'should return an image tag for a given theme file without parameters' do
    theme_image_tag('foo.jpg').should == "<img src=\"/sites/000000000000000000000042/theme/images/foo.jpg\" />"
  end
  
  it 'should return an image tag for a given theme file with size' do
    theme_image_tag('foo.jpg', 'width:100', 'height:100').should == "<img src=\"/sites/000000000000000000000042/theme/images/foo.jpg\" height=\"100\" width=\"100\" />"
  end

  it 'should return an image tag without parameters' do
    image_tag('foo.jpg').should == "<img src=\"foo.jpg\" />"
  end

  it 'should return an image tag with size' do
    image_tag('foo.jpg', 'width:100', 'height:50').should == "<img src=\"foo.jpg\" height=\"50\" width=\"100\" />"
  end

  it 'should return a flash tag without parameters' do
    flash_tag('foo.flv').should == %{
            <object>
              <param name="movie" value="foo.flv" />
              <embed src="foo.flv" />
              </embed>
            </object>
    }.strip
  end

  it 'should return a flash tag with size' do
    flash_tag('foo.flv', 'width:100', 'height:50').should == %{
            <object height=\"50\" width=\"100\">
              <param name="movie" value="foo.flv" />
              <embed src="foo.flv" height=\"50\" width=\"100\" />
              </embed>
            </object>
    }.strip
  end

  it 'should return a navigation block for the pagination' do
    pagination = {
      "previous"   => nil,
      "parts"     => [
        { 'title' => '1', 'is_link' => false },
        { 'title' => '2', 'is_link' => true, 'url' => '/?page=2' },
        { 'title' => '&hellip;', 'is_link' => false, 'hellip_break' => true },
        { 'title' => '5', 'is_link' => true, 'url' => '/?page=5' }
      ],
      "next" => { 'title' => 'next', 'is_link' => true, 'url' => '/?page=2' }
    }
    html = default_pagination(pagination, 'css:flickr_pagination')
    html.should match(/<div class="pagination flickr_pagination">/)
    html.should match(/<span class="disabled prev_page">&laquo; Previous<\/span>/)
    html.should match(/<a href="\/\?page=2">2<\/a>/)
    html.should match(/<span class=\"gap\">\&hellip;<\/span>/)
    html.should match(/<a href="\/\?page=2" class="next_page">Next &raquo;<\/a>/)

    pagination.merge!({
      'previous' => { 'title' => 'previous', 'is_link' => true, 'url' => '/?page=4' },
      'next'     => nil
    })

    html = default_pagination(pagination, 'css:flickr_pagination')
    html.should_not match(/<span class="disabled prev_page">&laquo; Previous<\/span>/)
    html.should match(/<a href="\/\?page=4" class="prev_page">&laquo; Previous<\/a>/)
    html.should match(/<span class="disabled next_page">Next &raquo;<\/span>/)

    pagination.merge!({ 'parts' => [] })
    html = default_pagination(pagination, 'css:flickr_pagination')
    html.should == ''
  end

  def build_context
    klass = Class.new
    klass.class_eval do
      def registers
        { :site => Factory.build(:site, :id => fake_bson_id(42)) }
      end

      def fake_bson_id(id)
        BSON::ObjectId(id.to_s.rjust(24, '0'))
      end
    end
    klass.new
  end



end
